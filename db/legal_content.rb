# Texto de privacidad y términos.
#
# Describe lo que el código realmente hace: cada dato nombrado acá existe en el
# esquema, y cada tercero nombrado es uno al que el navegador o el servidor
# efectivamente se conecta. Si cambia el sistema, cambia este texto.
#
# Se siembra siempre, no como contenido de muestra: Google exige que estas
# páginas existan y sean públicas para publicar la pantalla de consentimiento.
LEGAL_CONTENT = {
  [ "privacy", "es" ] => {
    title: "Privacidad",
    subtitle: "Qué datos guardamos, por qué, y qué podés pedirnos.",
    body: <<~HTML
      <p>Esta es una escuela chica. No vendemos datos, no hacemos publicidad y no usamos herramientas de seguimiento. Lo que sigue es la lista completa de lo que el sitio guarda.</p>

      <h2>Qué guardamos</h2>
      <p><strong>Si escribís por el formulario de contacto:</strong> tu nombre, tu correo, tu teléfono si lo dejás, el mensaje, el curso por el que consultás y el idioma en que estabas leyendo. Lo guardamos para poder responderte.</p>
      <p><strong>Si te creás una cuenta:</strong> tu nombre y tu correo. La contraseña no se guarda: se guarda un resumen criptográfico del que no se puede recuperar el original. Si entrás con Google, guardamos tu correo, tu nombre y el identificador que Google nos da; nunca vemos tu contraseña de Google.</p>
      <p><strong>Cada vez que iniciás sesión:</strong> tu dirección IP y qué navegador usaste. Sirve para que puedas ver dónde hay sesiones abiertas y para detectar accesos que no reconozcas.</p>
      <p><strong>Si te inscribís a un curso:</strong> a cuál y desde cuándo.</p>

      <h2>Cookies</h2>
      <p>Una sola, firmada, que mantiene tu sesión abierta. Sin ella no podrías mantener la sesión de una página a otra. No hay cookies de analítica ni de publicidad, propias ni de terceros.</p>

      <h2>Con quién se comparte</h2>
      <p>Con nadie, en el sentido de vender o ceder. Sí usamos servicios que procesan datos por cuenta nuestra:</p>
      <ul>
        <li><strong>Fly.io</strong> — aloja el sitio y la base de datos. Los servidores están en São Paulo, Brasil, así que tus datos se almacenan fuera de Argentina.</li>
        <li><strong>Cloudflare</strong> — guarda los archivos (videos, imágenes, documentos) y resuelve el dominio.</li>
        <li><strong>Resend</strong> — entrega los correos que te enviamos.</li>
        <li><strong>Google</strong> — si elegís entrar con Google. Además, las tipografías del sitio se cargan desde sus servidores, lo que significa que Google recibe tu dirección IP al abrir cualquier página.</li>
        <li><strong>YouTube o Vimeo</strong> — sólo en las clases cuyo video esté alojado ahí. Los videos de YouTube se insertan en modo sin cookies.</li>
      </ul>

      <h2>Cuánto tiempo</h2>
      <p>Los mensajes de contacto y las cuentas se conservan mientras la escuela funcione o hasta que pidas que los borremos. Las sesiones se borran cuando cerrás sesión o cambiás tu contraseña.</p>

      <h2>Tus derechos</h2>
      <p>Podés pedirnos en cualquier momento que te digamos qué datos tuyos tenemos, que los corrijamos o que los borremos. Alcanza con escribir a <a href="mailto:hola@volveralalma.com.ar">hola@volveralalma.com.ar</a>.</p>
      <p>En Argentina estos derechos están amparados por la Ley 25.326 de Protección de los Datos Personales, y la Agencia de Acceso a la Información Pública es el organismo de control ante el que podés reclamar.</p>

      <h2>Cambios</h2>
      <p>Si esto cambia, cambia esta página. La fecha de la última modificación es la que figura al pie del sitio.</p>
    HTML
  },
  [ "terms", "es" ] => {
    title: "Términos del servicio",
    subtitle: "Las condiciones de uso del sitio y de los cursos.",
    body: <<~HTML
      <h2>Qué es esto</h2>
      <p>Volver al alma es una escuela de bienestar: cursos, encuentros y prácticas de atención plena, movimiento y trabajo contemplativo.</p>

      <h2>Lo más importante: esto no es tratamiento médico</h2>
      <p>Quien dicta los cursos es médica psiquiatra, pero <strong>los cursos no son psicoterapia, ni tratamiento médico, ni reemplazan una consulta profesional</strong>. Tomar un curso no crea una relación médico-paciente.</p>
      <p>Si estás atravesando un cuadro de salud mental, tomando medicación psiquiátrica, o en tratamiento, consultá con tu profesional antes de empezar. Si estás en una crisis, buscá atención inmediata: en Argentina la línea de asistencia al suicidio es el <strong>135</strong> (CABA y GBA) o <strong>0800 345 1435</strong> desde todo el país.</p>
      <p>Las prácticas contemplativas son seguras para la mayoría de las personas, pero pueden remover cosas. Si algo te hace mal, parás. Nada de lo que enseñamos vale más que tu criterio sobre tu propio cuerpo.</p>

      <h2>Tu cuenta</h2>
      <p>Es personal. Sos responsable de lo que pase con ella y de mantener la contraseña a resguardo. Si creés que alguien más entró, avisanos.</p>

      <h2>Los cursos</h2>
      <p>A los cursos sin costo te sumás por tu cuenta desde el sitio. Los cursos pagos se coordinan por el formulario de contacto.</p>
      <p>El material de los cursos —videos, textos, prácticas— es para vos. No se puede compartir, descargar para redistribuir, ni publicar en otro lado.</p>

      <h2>Cancelaciones y devoluciones</h2>
      <p>Se acuerdan caso por caso: escribinos y lo resolvemos. Cuando haya cursos pagos con inscripción abierta, las condiciones concretas van a estar en cada curso.</p>

      <h2>Cambios</h2>
      <p>Si estas condiciones cambian, cambia esta página. Si el cambio te afecta en un curso que ya empezaste, te lo avisamos.</p>

      <h2>Dónde se resuelve un conflicto</h2>
      <p>Estos términos se rigen por la ley argentina.</p>

      <h2>Escribinos</h2>
      <p>Cualquier duda sobre esto: <a href="mailto:hola@volveralalma.com.ar">hola@volveralalma.com.ar</a>.</p>
    HTML
  }
}.freeze
