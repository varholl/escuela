# Deploy a Fly.io

El sitio corre en **una sola máquina** con un volumen. La base es SQLite: una
segunda máquina tendría su propia copia del volumen y las dos se separarían en
silencio. No escalar más allá de `count 1`.

## Primera vez

```bash
fly auth login

# Crea la app sin desplegarla todavía ni tocar fly.toml.
fly apps create maflor

# El volumen guarda la base Y los archivos subidos (portadas, retrato).
fly volumes create maflor_storage --region eze --size 3

# La master key de Rails: sin esto la app no arranca.
fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)"

# Dominio que usan los enlaces de los correos.
fly secrets set APP_HOST="maflor.fly.dev"

# Dónde llegan los mensajes del formulario de contacto.
fly secrets set CONTACT_RECIPIENT="flor@ejemplo.com" MAILER_SENDER="hola@maflor.com"

fly deploy
fly scale count 1
```

El `bin/docker-entrypoint` corre `db:prepare` en cada arranque, así que las
migraciones se aplican solas.

### Crear la usuaria administradora en producción

```bash
fly ssh console --command "/rails/bin/rails db:seed"
```

Imprime la contraseña generada una única vez — anotala y cambiala desde el panel.
O fijala vos:

```bash
fly ssh console --command \
  "env ADMIN_EMAIL=flor@ejemplo.com ADMIN_PASSWORD=... /rails/bin/rails db:seed"
```

## Correo

Hasta que configures SMTP, el formulario de contacto **igual guarda todos los
mensajes** en la base y se leen en `/admin/inquiries`; sólo no sale el aviso por
correo. Para activarlo (Resend, Postmark, SendGrid, el que sea):

```bash
fly secrets set \
  SMTP_ADDRESS="smtp.resend.com" \
  SMTP_PORT="587" \
  SMTP_USER_NAME="resend" \
  SMTP_PASSWORD="..."
```

## Dominio propio

```bash
fly certs add maflor.com
fly certs add www.maflor.com
fly secrets set APP_HOST="maflor.com"
```

Fly indica los registros DNS a cargar (un `A`, un `AAAA` y un `CNAME`).

## Día a día

```bash
fly deploy                    # desplegar
fly logs                      # ver qué pasa
fly ssh console               # entrar a la máquina
fly console                   # consola de Rails
fly volumes snapshots list maflor_storage
```

## Copias de seguridad

Fly saca snapshots diarios del volumen y los guarda 14 días (`fly.toml`). Para
bajar una copia de la base cuando quieras:

```bash
fly ssh sftp get /rails/storage/production.sqlite3 ./backup.sqlite3
```

Vale la pena hacerlo antes de cualquier cambio grande.

## Problemas conocidos

**El arranque falla diciendo que no puede escribir en `storage/`.** El volumen
se montó como root y la app corre con el usuario `rails` (uid 1000):

```bash
fly ssh console --command "chown -R 1000:1000 /rails/storage"
fly apps restart maflor
```

**Las imágenes no se procesan.** El contenedor ya trae `libvips`. Si pasa en tu
máquina y no en producción, es que falta `brew install vips` local.
