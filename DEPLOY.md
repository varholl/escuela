# Deploy a Fly.io

**En línea:** <https://maflor-escuela.fly.dev>

El sitio corre en **una sola máquina** con un volumen. La base es SQLite: una
segunda máquina tendría su propia copia del volumen y las dos se separarían en
silencio. No escalar más allá de `count 1`.

Los pasos de abajo ya se ejecutaron; quedan documentados para rehacerlo o para
levantar un entorno de staging.

## Primera vez

```bash
fly auth login

fly apps create maflor-escuela

# Fly no tiene región en Argentina; gru (Sao Paulo) es la más cercana,
# ~30 ms desde Buenos Aires.
fly volumes create maflor_storage --app maflor-escuela --region gru --size 3 --yes

# La master key de Rails: sin esto la app no arranca.
fly secrets set --app maflor-escuela RAILS_MASTER_KEY="$(cat config/master.key)"

# Dominio para los enlaces de los correos y destino del formulario.
fly secrets set --app maflor-escuela \
  APP_HOST="maflor-escuela.fly.dev" \
  CONTACT_RECIPIENT="maflordiiorio@gmail.com" \
  MAILER_SENDER="maflordiiorio@gmail.com"

fly deploy --ha=false
```

`--ha=false` evita que Fly cree dos máquinas, que es justo lo que SQLite no
tolera.

### Por qué el puerto 8080

La imagen corre como usuario `rails` (uid 1000), y en Linux un proceso sin
privilegios no puede escuchar en puertos menores a 1024. Con el `internal_port =
80` que trae Rails por defecto, Thruster falla con `bind: permission denied` y la
máquina reinicia en loop. Por eso `fly.toml` fija `HTTP_PORT = "8080"` y
`internal_port = 8080`. El proxy de Fly sigue atendiendo 443 hacia afuera.

### La usuaria administradora

```bash
fly ssh console --app maflor-escuela --user rails \
  --command "env ADMIN_EMAIL=... ADMIN_NAME=... ADMIN_PASSWORD=... /rails/bin/rails db:seed"
```

`--user rails` importa: por omisión `fly ssh console` entra como root, y correr
Rails como root deja archivos `-wal`/`-shm` de SQLite con dueño equivocado en el
volumen, que después la app no puede escribir.

> **El contenido de muestra no se siembra en producción.** `bin/docker-entrypoint`
> corre `db:prepare` en cada arranque, y `db:prepare` ejecuta las semillas cuando
> la base está recién creada. Como el seed traía notas y biografías inventadas,
> el primer despliegue las publicó en el sitio en vivo y hubo que borrarlas a
> mano. Hoy `db/seeds.rb` sólo siembra la cuenta administradora y las páginas
> vacías fuera de desarrollo; para forzar el contenido de muestra,
> `SEED_SAMPLE_CONTENT=1`.

## Correo

**Todavía sin configurar.** El formulario de contacto guarda todos los mensajes
en la base y se leen en `/admin/inquiries`; simplemente no sale el aviso por
correo, y la app ni siquiera intenta enviarlo para no acumular trabajos fallidos.

Para activarlo con cualquier proveedor (Resend, Postmark, SendGrid):

```bash
fly secrets set --app maflor-escuela \
  SMTP_ADDRESS="smtp.resend.com" \
  SMTP_PORT="587" \
  SMTP_USER_NAME="resend" \
  SMTP_PASSWORD="..."
```

Con `SMTP_ADDRESS` presente, la app pasa sola a enviar de verdad.

## Dominio propio

```bash
fly certs add --app maflor-escuela maflor.com
fly certs add --app maflor-escuela www.maflor.com
fly secrets set --app maflor-escuela APP_HOST="maflor.com"
```

Fly indica los registros DNS a cargar (un `A`, un `AAAA` y un `CNAME`).

## Día a día

```bash
fly deploy --ha=false                     # desplegar
fly logs --app maflor-escuela             # ver qué pasa
fly ssh console --app maflor-escuela --user rails
fly console --app maflor-escuela          # consola de Rails
fly status --app maflor-escuela
```

## Copias de seguridad

Fly saca snapshots diarios del volumen. Para bajar una copia de la base:

```bash
fly ssh sftp get /rails/storage/production.sqlite3 ./backup.sqlite3 --app maflor-escuela
```

Vale la pena hacerlo antes de cualquier cambio grande.

## Notas

- **El volumen monta con el dueño correcto.** Fly lo monta con `uid 1000, gid
  1000`, así que no hace falta ningún `chown`.
- **Solid Queue corre dentro de Puma** (`SOLID_QUEUE_IN_PUMA=true`), sin una
  segunda máquina. Verificado: procesa los trabajos encolados.
- **El primer pedido tras una suspensión tarda unos segundos** mientras la
  máquina se reanuda. Con `min_machines_running = 1` eso pasa rara vez.
