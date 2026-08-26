# Maflor

Escuela de bienestar: sitio público, notas y cursos, con un panel de
administración propio.

**En línea:** <https://volveralalma.com.ar>

> «Un espacio de desarrollo del ser, en la coherencia cuerpo-mente-espíritu.»

El código, los nombres de clases, variables y ramas están en inglés. Los textos
de cara al público viven en `config/locales/` (español e inglés).

---

## Puesta en marcha

Requiere Ruby 3.3.6 (ya instalado vía RVM) y, para procesar imágenes, `libvips`.

```bash
brew install vips        # necesario para las imágenes de portada y el retrato
bundle install
bin/rails db:prepare
bin/rails db:seed        # crea el usuario administrador e imprime su contraseña
bin/dev                  # servidor + compilación de Tailwind en modo watch
```

`bin/dev` levanta el sitio en <http://localhost:3000>.

> Usá siempre `bin/dev` y no `bin/rails server`: Tailwind v4 genera el CSS
> leyendo las clases que aparecen en las vistas, así que sin el watcher los
> estilos nuevos no aparecen.

### Usuario administrador

`db:seed` crea uno y muestra la contraseña generada por única vez. Para fijarla:

```bash
ADMIN_EMAIL=flor@ejemplo.com ADMIN_PASSWORD=... bin/rails db:seed
```

El acceso al panel está en `/session/new` y el panel en `/admin`.

---

## Cómo está armado

### Modelo de contenido

| Modelo       | Para qué                                                                 |
|--------------|--------------------------------------------------------------------------|
| `Article`    | Las notas. Texto rico con Action Text, imagen de portada, publicación con fecha. |
| `Course`     | Cursos y encuentros: precio, modalidad, fecha de inicio, estado.          |
| `Lesson`     | Las clases de un curso: video, material y orden. Sólo visibles con inscripción. |
| `Enrollment` | Quién puede ver qué curso. A los gratuitos cada quien se suma por su cuenta. |
| `Page`       | Textos editables sin deploy: «Sobre mí», «Filosofía», y el video institucional del inicio. |
| `Inquiry`    | Los mensajes del formulario de contacto.                                 |
| `User`       | Personas. `role` distingue `student` de `admin`.                         |

Tres concerns transversales en `app/models/concerns/`:

- **`Sluggable`** — genera el slug a partir del título y no lo vuelve a tocar,
  para que un enlace ya compartido siga funcionando aunque se edite el título.
- **`Publishable`** — `published_at` vacío es borrador; una fecha futura deja la
  publicación programada.
- **`Localizable`** — cada contenido se escribe una vez por idioma. Una nota en
  español y su versión en inglés son dos registros distintos, no una traducción
  campo por campo. El sitio sólo lista los que coinciden con el idioma activo.

### Una sola dirección

`APP_HOST` define el host canónico. Todo lo demás —`www`, el nombre de
`fly.dev`— redirige ahí con un 301, así un enlace compartido siempre es el mismo
enlace y los buscadores ven un sitio y no tres copias.

La redirección vive en `ApplicationController`, no en Cloudflare, porque el
nombre de `fly.dev` no pasa por Cloudflare y quedaría afuera. `/up` no se ve
afectado: el controlador de salud de Rails no hereda de ahí, así que los chequeos
de Fly siguen funcionando.

### Idiomas y URLs

El español se sirve desde la raíz (`/notas`) y el inglés bajo `/en` (`/en/notas`).
Los segmentos de las rutas quedan en español en los dos idiomas: es la audiencia
principal y evita duplicar los nombres de las rutas.

> **Cuidado al agregar enlaces.** Como `:locale` es un segmento opcional
> adelante, un argumento posicional se asigna al idioma y no al `:id`. Siempre:
>
> ```erb
> <%= link_to article.title, article_path(id: article) %>   <%# sí %>
> <%= link_to article.title, article_path(article) %>       <%# no: rompe %>
> ```

### Diseño

Todo el sistema visual sale del logo, que es una elipse precisa dibujada
alrededor de caligrafía suelta. Los colores están tomados con cuentagotas del
propio degradado del logo (violeta `#7717b5` → rosa `#b0636a` → dorado `#dba51b`)
y viven como tokens en `app/assets/tailwind/application.css`.

Dos decisiones que conviene no deshacer sin querer:

- Los tres pilares (cuerpo, mente, espíritu) se marcan con **tercios de un mismo
  anillo**, no con números: no son una secuencia, son simultáneos.
- Los estilos de `.prose-note` y los de `trix-editor` están **fuera** de
  `@layer components` a propósito. Action Text trae reglas sin capa
  (`.trix-content * { margin: 0 }` y `trix-editor { min-height: 5em }`), y en la
  cascada de CSS lo que está sin capa le gana a cualquier capa sin importar la
  especificidad. Metidos en la capa, esos estilos se pierden en silencio: los
  párrafos quedan pegados y el editor queda de cinco renglones.

Tipografías: **Newsreader** para títulos y **Karla** para texto, desde Google Fonts.

### Páginas de error

Un enlace viejo o un borrador dan un 404 con la identidad del sitio, no el de
Rails: `config.exceptions_app` enruta los errores por `ErrorsController`, que
además conserva el idioma que estaba leyendo el visitante. Los `public/*.html`
quedan como último recurso para cuando la aplicación no puede ni renderizar.

> Si en desarrollo el CSS parece no actualizarse, borrá los assets precompilados
> que pudo dejar una prueba de producción: `bin/rails assets:clobber`. Mientras
> existan, `public/assets/` se sirve antes que Propshaft.

---

## El video del inicio

Vive en la página `home` (`/admin/pages`), así que ella lo cambia sin deploy. Se
muestra en la sección «Rigor clínico, mirada contemplativa», que es donde la
página deja de describir la escuela y empieza a describirla a ella.

- **`preload="none"`**: no se descarga un solo byte hasta que alguien le da play.
- **El póster sale del propio video**, con ffmpeg. No hay que subir una imagen aparte.
- Es **público** —es la escuela presentándose— pero el bucket sigue siendo
  privado: sale por `/video/home`, que redirige a un enlace firmado.

Si el video es vertical se ve como un teléfono; si es apaisado ocupa el ancho.

## Correo

**Apagado hasta que haya dominio propio.** `config.x.email_enabled` es false en
producción mientras no exista `SMTP_ADDRESS`, y `ApplicationMailer` cancela la
entrega de cualquier correo con un `after_action`, así que un mailer nuevo no se
puede olvidar de respetarlo.

El motivo no es pereza: mandar "desde" una dirección `@gmail.com` a través del
servidor de otro rompe la alineación de DMARC y termina en spam. Para avisarle a
ella da igual; para escribirle a estudiantes, no.

Nada depende del correo para funcionar: el formulario de contacto **siempre**
guarda el mensaje, y quien se registra elige su propia contraseña. Lo único que
no se puede sin correo es recuperar la contraseña — y la pantalla de ingreso deja
de ofrecerlo cuando no puede cumplirlo, en vez de decir "te enviamos las
instrucciones" sin enviar nada.

Los tres correos automáticos ya están escritos, traducidos y con tests:

| Cuándo | Qué |
|---|---|
| Se registra | Bienvenida, con el enlace a «Mis cursos» |
| Pide recuperar la contraseña | Enlace para elegir una nueva, con su vencimiento |
| Le dan acceso a un curso desde el panel | Aviso con el enlace al curso |

Salen en el idioma que la persona estaba leyendo: Active Job guarda el locale en
el trabajo y lo restaura al enviarlo.

Se pueden mirar sin enviar nada en `/rails/mailers` (sólo en desarrollo).

Para encenderlo: configurar SMTP como indica [`DEPLOY.md`](DEPLOY.md) y
comprobar con `bin/rails mail:test`, que entrega en el momento y falla ruidosa
si algo está mal.

## Cursos y estudiantes

A los cursos **sin costo** cada quien se suma por su cuenta: se registra eligiendo su
propia contraseña y la inscripción queda hecha en el mismo paso. Todo el camino funciona
**sin enviar un solo correo**, que es lo que permite que ande hoy.

Los cursos son **privados**. Sin inscripción no se ve ninguna clase, ni
aunque alguien comparta el enlace directo:

| | Clase publicada | Clase sin publicar |
|---|---|---|
| Visitante sin cuenta | no | no |
| Con cuenta, sin inscripción | no | no |
| Con inscripción al curso | **sí** | no |
| Ella (admin) | sí | sí |

La lista de clases del curso sí es pública: sirve de índice, muestra los títulos
y la duración, pero ninguno de esos títulos abre nada sin inscripción.

Un curso **con precio** no se puede tomar solo: muestra el formulario de
contacto, hasta que haya pasarela de pago. Ella igual puede dar acceso a mano
desde el panel, a cualquier curso.

### Dónde poner el video

Cerrar la página **no alcanza** por sí solo: si el video vive en un servicio
público, su URL sigue siendo pública aunque el sitio esté cerrado con llave.

| Hosting | ¿Queda realmente privado? |
|---|---|
| **Subido al sitio** → Cloudflare R2 | **Sí.** Ver abajo. Es lo que está configurado. |
| **Vimeo** | **Sí, si lo configurás**: privacidad «sólo en sitios que elija» y agregás el dominio. Es la opción recomendada para lo pago. |
| **Mux** | **Sí**, con URLs firmadas. Lo más sólido, y lo que conviene si esto crece. |
| **YouTube «no listado»** | **No.** Cualquiera con el enlace lo mira en YouTube. Sirve para material gratuito o de difusión, no para un curso cerrado. |

Los embeds de YouTube van en modo `nocookie`, así que ver una clase no entrega a
quien mira al perfil publicitario de Google — pero eso es privacidad de datos,
no control de acceso.

### Cloudflare R2

Los archivos subidos van a R2 (bucket `videos`), configurado en
`config/storage.yml` como servicio `cloudflare`. Las credenciales viven en los
secrets de Fly, nunca en el repo.

`LessonVideosController` decide **primero** si esa persona está inscripta, y
recién entonces entrega el archivo. Nunca se enlaza la URL de Active Storage
directamente, porque su identificador firmado se puede reenviar.

Hay dos formas de entregar, y la diferencia es plata:

- **`redirect`** (por defecto) — devuelve una URL firmada a R2 y el navegador
  baja el archivo directo de Cloudflare. **Egreso desde R2: gratis.** La URL vive
  `VIDEO_LINK_MINUTES` (120 por defecto); tiene que durar más que la clase,
  porque adelantar el video vuelve a pedir la misma URL.
- **`proxy`** — todo pasa por la aplicación, así que ninguna URL usable sale del
  servidor. Es más estricto, pero **cada GB visto se factura como egreso de Fly
  ($0,04/GB desde São Paulo)** y ocupa la máquina. Se activa con
  `fly secrets set VIDEO_DELIVERY=proxy`.

**La duración se completa sola.** El contenedor trae `ffmpeg`, así que al subir
un video Active Storage lee su duración y la carga en la clase. Un valor puesto
a mano nunca se pisa: puede querer anunciar el tiempo de práctica y no el largo
del archivo. Sin `ffmpeg` esto no funciona y el campo queda manual — es lo único
que ese paquete aporta, y son ~125 MB de imagen.

**Subida directa.** El campo del video usa `direct_upload: true`: el archivo
viaja del navegador a R2 sin pasar por la aplicación. Sin eso, un video de
cientos de megas se bufferearía por el proxy de Fly y por Puma.

Eso obliga a que R2 acepte un `PUT` desde el origen del sitio. La política se
carga una sola vez en **Cloudflare → R2 → bucket → Settings → CORS Policy**; la
tarea `bin/rails r2:configure_cors` la imprime lista para pegar (no puede
aplicarla sola porque el token de la aplicación tiene permisos sólo sobre
objetos, que es como debe ser).

### Cómo se ordenan los archivos

Active Storage le pone a cada archivo un nombre al azar, lo cual está bien para
la aplicación e inservible para alguien que abre el panel de Cloudflare. Cada
archivo se reubica, después de guardar, en una ruta legible:

```
cursos/<curso>/<clase>/clase-uno.mp4
cursos/<curso>/<clase>/guia-de-practica.pdf
cursos/<curso>/portada.jpg
notas/<nota>/foto.jpg
paginas/about-es/retrato.jpg
paginas/about-es/variantes/retrato.jpg      ← miniaturas generadas
```

**Después**, y no antes, porque con subida directa el archivo llega al bucket
antes de que se envíe el formulario: en ese momento todavía no se sabe a qué
clase pertenece, y si la clase es nueva, ni siquiera existe. La mudanza es una
copia del lado del servidor, así que los bytes de un video no viajan de ida y
vuelta.

```bash
bin/rails storage:list           # qué hay y dónde
bin/rails storage:organise       # reubicar lo ya subido (se puede repetir)
bin/rails storage:purge_orphans  # borrar subidas que quedaron a medias
```

Lo último también corre solo, todos los días a las 4am (`config/recurring.yml`):
un formulario abandonado deja el archivo en el bucket sin nada que lo referencie,
y se paga igual.

### Adjuntos en el material de apoyo

El partial que genera Rails muestra un archivo que no es imagen como un
`figcaption` pelado — el nombre como texto plano, sin enlace. Está reemplazado
por una tarjeta descargable con la extensión, el peso y `disposition:
"attachment"` en la URL firmada.

> Sin `<svg>` a propósito: Action Text sanitiza el adjunto renderizado y
> `svg`/`path` no están en la lista permitida, así que desaparecen sin avisar.
> Ampliar esa lista dejaría pasar SVG en texto que escribe cualquiera, que es un
> vector de XSS a cambio de un ícono.

Y sus estilos van **sin capa**, por lo mismo que `.prose-note`: dentro de
`.trix-content`, las utilidades de Tailwind pierden contra el
`* { margin: 0; padding: 0 }` de `actiontext.css`.

> **Dos ajustes de `storage.yml` que no son opcionales:**
> `request_checksum_calculation` y `response_checksum_validation` en
> `when_required`. Las versiones recientes de `aws-sdk-s3` mandan varios
> checksums a la vez y R2 responde *"You can only specify one checksum at a
> time"*, lo que hace fallar todas las subidas.

Lo que se subió **antes** de conectar R2 sigue en el volumen de Fly y funciona
igual: Active Storage guarda el servicio archivo por archivo.

## Trabajo diario de ella

Todo desde `/admin`, sin tocar código:

- **Notas** — escribir, adjuntar portada, guardar como borrador y publicar
  cuando quiera (o dejar programada una fecha).
- **Cursos** — cargar, ordenar, poner precio y publicar. Dentro de cada curso
  están las clases y las inscripciones.
- **Páginas** — reescribir «Sobre mí» y «Filosofía», y subir su retrato (el
  retrato aparece dentro de la elipse del inicio).
- **Mensajes** — leer las consultas, responder por correo y marcarlas.

---

## Tests

```bash
bin/rails test
```

171 tests cubren los modelos, el ruteo por idioma, que los borradores no se
filtren, el formulario de contacto (incluido el honeypot), las páginas de error, quién
puede ver cada clase (incluido que un enlace compartido no abra para nadie de
afuera), el registro y la inscripción a cursos gratuitos, y que el panel sólo
sea accesible para administradores.

---

## Contenido de muestra

El sitio arranca poblado con notas, cursos y biografías **inventados**, para que
no sea una página en blanco mientras ella escribe lo suyo. Están firmados como
si fueran de ella, así que hay una forma de sacarlos de un comando:

```bash
bin/rails sample_content:list      # qué queda de muestra
bin/rails sample_content:remove    # borrarlo (respeta lo que ella ya reescribió)
```

En producción:

```bash
fly ssh console --app maflor-escuela --user rails \
  --command "/rails/bin/rails sample_content:remove"
```

`db:seed` sólo carga contenido de muestra fuera de producción; para forzarlo,
`SEED_SAMPLE_CONTENT=1`.

### Buscadores

Mientras el texto sea inventado, el sitio está cerrado a los buscadores: el
`robots.txt` prohíbe todo y cada página lleva `noindex`. Cuando el contenido sea
realmente de ella:

```bash
fly secrets set --app maflor-escuela ALLOW_INDEXING=true
```

`robots.txt` lo sirve la aplicación (no `public/`) justamente para que siga ese
interruptor.

## Cambiar el nombre

*Maflor* es provisorio y aparece en pocos lugares:

1. `config/locales/es.yml` y `en.yml` → clave `site.name`.
2. `fly.toml` → `app` y el nombre del volumen.
3. El módulo Ruby `Maflor` en `config/application.rb` y `config.ru` — cambiarlo
   es opcional; no se ve en ningún lado.

Fly no permite renombrar una app, así que `maflor-escuela.fly.dev` queda fijo.
En cuanto haya dominio propio deja de importar: ver `DEPLOY.md`.

Los logos están en `app/assets/images/` (`logo-mark.png` para fondo claro,
`logo-mark-light.png` para fondo oscuro) y los favicons en `public/`.

---

## Qué falta

- **Fase 2: venta y suscripciones.** El diseño está en
  [`docs/PHASE_2.md`](docs/PHASE_2.md).
- **Paginación de notas.** Hoy `/notas` lista todo. Recién hace falta pasadas
  unas treinta notas.
- **Correo.** El formulario guarda todo, pero el aviso por correo necesita
  SMTP configurado. Ver [`DEPLOY.md`](DEPLOY.md).
