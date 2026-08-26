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
      <p>Una sola, firmada, que mantiene tu sesión abierta. Sin ella no podrías seguir conectada de una página a otra. No hay cookies de analítica ni de publicidad, propias ni de terceros.</p>

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
      <p>A los cursos sin costo te sumás sola desde el sitio. Los cursos pagos se coordinan por el formulario de contacto.</p>
      <p>El material de los cursos —videos, textos, prácticas— es para vos. No se puede compartir, descargar para redistribuir, ni publicar en otro lado.</p>

      <h2>Cancelaciones y devoluciones</h2>
      <p>Se acuerdan caso por caso: escribinos y lo resolvemos. Cuando haya cursos pagos con inscripción abierta, las condiciones concretas van a estar en cada curso.</p>

      <h2>Cambios</h2>
      <p>Si estas condiciones cambian, cambia esta página. Si el cambio te afecta como alumna de un curso en marcha, te lo avisamos.</p>

      <h2>Dónde se resuelve un conflicto</h2>
      <p>Estos términos se rigen por la ley argentina.</p>

      <h2>Escribinos</h2>
      <p>Cualquier duda sobre esto: <a href="mailto:hola@volveralalma.com.ar">hola@volveralalma.com.ar</a>.</p>
    HTML
  },
  [ "privacy", "en" ] => {
    title: "Privacy",
    subtitle: "What we keep, why, and what you can ask of us.",
    body: <<~HTML
      <p>This is a small school. We do not sell data, we do not advertise, and we use no tracking tools. What follows is the complete list of what the site keeps.</p>

      <h2>What we keep</h2>
      <p><strong>If you write through the contact form:</strong> your name, your email, your phone if you leave one, the message, the course you are asking about, and the language you were reading in. We keep it so we can answer you.</p>
      <p><strong>If you create an account:</strong> your name and your email. The password itself is not stored — only a cryptographic digest the original cannot be recovered from. If you sign in with Google we keep your email, your name and the identifier Google gives us; we never see your Google password.</p>
      <p><strong>Every time you sign in:</strong> your IP address and which browser you used, so you can see where sessions are open and spot any you do not recognise.</p>
      <p><strong>If you join a course:</strong> which one, and from when.</p>

      <h2>Cookies</h2>
      <p>One, signed, that keeps you signed in from page to page. There are no analytics or advertising cookies, ours or anyone else's.</p>

      <h2>Who it is shared with</h2>
      <p>Nobody, in the sense of selling or handing over. We do use services that process data on our behalf:</p>
      <ul>
        <li><strong>Fly.io</strong> — hosts the site and the database. The servers are in São Paulo, Brazil, so your data is stored outside Argentina.</li>
        <li><strong>Cloudflare</strong> — stores the files (videos, images, documents) and resolves the domain.</li>
        <li><strong>Resend</strong> — delivers the mail we send you.</li>
        <li><strong>Google</strong> — if you choose to sign in with Google. The site's typefaces are also loaded from their servers, which means Google receives your IP address when you open any page.</li>
        <li><strong>YouTube or Vimeo</strong> — only on sessions whose video is hosted there. YouTube videos are embedded in no-cookie mode.</li>
      </ul>

      <h2>For how long</h2>
      <p>Contact messages and accounts are kept while the school runs, or until you ask us to delete them. Sessions are deleted when you sign out or change your password.</p>

      <h2>Your rights</h2>
      <p>You can ask us at any time what data of yours we hold, to correct it, or to delete it. Write to <a href="mailto:hola@volveralalma.com.ar">hola@volveralalma.com.ar</a>.</p>
      <p>In Argentina these rights are covered by Law 25.326 on the Protection of Personal Data, and the Agencia de Acceso a la Información Pública is the authority you can complain to.</p>

      <h2>Changes</h2>
      <p>If this changes, this page changes.</p>
    HTML
  },
  [ "terms", "en" ] => {
    title: "Terms of service",
    subtitle: "The conditions for using the site and the courses.",
    body: <<~HTML
      <h2>What this is</h2>
      <p>Volver al alma is a wellbeing school: courses, gatherings and practices in mindfulness, movement and contemplative work.</p>

      <h2>The important part: this is not medical treatment</h2>
      <p>The courses are taught by a psychiatrist, but <strong>they are not psychotherapy, not medical treatment, and not a substitute for professional care</strong>. Taking a course does not create a doctor–patient relationship.</p>
      <p>If you are going through a mental health condition, taking psychiatric medication, or in treatment, talk to your own professional before starting. If you are in crisis, seek immediate help — in Argentina the suicide helpline is <strong>135</strong> (Buenos Aires) or <strong>0800 345 1435</strong> nationwide.</p>
      <p>Contemplative practice is safe for most people, but it can stir things up. If something does not feel right, stop. Nothing we teach outranks your own judgement about your own body.</p>

      <h2>Your account</h2>
      <p>It is personal. You are responsible for what happens through it and for keeping your password safe. If you think someone else has been in it, tell us.</p>

      <h2>The courses</h2>
      <p>You join free courses yourself from the site. Paid courses are arranged through the contact form.</p>
      <p>Course material — videos, texts, practices — is for you. It may not be shared, downloaded for redistribution, or published elsewhere.</p>

      <h2>Cancellations and refunds</h2>
      <p>Agreed case by case: write to us and we will sort it out. Once paid courses open for enrolment, the specific terms will be stated on each course.</p>

      <h2>Changes</h2>
      <p>If these conditions change, this page changes. If a change affects you as a student on a course already under way, we will tell you.</p>

      <h2>Governing law</h2>
      <p>These terms are governed by Argentine law.</p>

      <h2>Get in touch</h2>
      <p>Any question about this: <a href="mailto:hola@volveralalma.com.ar">hola@volveralalma.com.ar</a>.</p>
    HTML
  }
}.freeze
