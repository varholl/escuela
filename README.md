# Maflor

Escuela de bienestar: sitio público, notas y cursos, con un panel de
administración propio.

**En línea:** <https://maflor-escuela.fly.dev>

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
| `Lesson`     | Las clases de un curso. Cargadas pero **todavía no visibles** al público. |
| `Enrollment` | Quién puede ver qué curso. Hoy se otorga a mano desde el panel.           |
| `Page`       | Los textos de «Sobre mí» y «Filosofía», editables sin deploy.             |
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

102 tests cubren los modelos, el ruteo por idioma, que los borradores no se
filtren, el formulario de contacto (incluido el honeypot), las páginas de error y que el
panel sólo sea accesible para administradores.

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
