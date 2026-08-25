# Idempotent: safe to run again on an existing database. Nothing here is
# destructive, and existing records keep whatever the owner has edited.
#
# Two tiers:
#   always        the administrator account and one empty Page per key/locale
#   sample only   invented notes, courses and biographies
#
# The sample tier never runs in production. It reads as her own writing, and
# publishing invented biography under a real doctor's name is not a mistake
# worth risking for the convenience of a populated homepage. Pass
# SEED_SAMPLE_CONTENT=1 to force it anywhere.
seed_samples = ENV["SEED_SAMPLE_CONTENT"].present? || !Rails.env.production?

puts "\n  Seeding #{Rails.env} (sample content: #{seed_samples ? "yes" : "no"})"

# ---------------------------------------------------------------------------
# Administrator
# ---------------------------------------------------------------------------
# Re-running the seed must never invent a second administrator. Without an
# explicit ADMIN_EMAIL, an existing admin is left exactly as it is.
if ENV["ADMIN_EMAIL"].blank? && User.admin.exists?
  puts "  Administrator already present: #{User.admin.pick(:email_address)}"
else
  admin_email = ENV.fetch("ADMIN_EMAIL", "admin@maflor.local")
  admin = User.find_or_initialize_by(email_address: admin_email)

  if admin.new_record?
    generated_password = ENV["ADMIN_PASSWORD"].presence || SecureRandom.base58(20)
    admin.assign_attributes(
      name: ENV.fetch("ADMIN_NAME", "Administración"),
      role: :admin,
      password: generated_password,
      password_confirmation: generated_password
    )
    admin.save!

    puts "\n  Administrator created"
    puts "    email:    #{admin.email_address}"
    puts "    password: #{generated_password}"
    puts "    Sign in at /session/new and change it from the panel.\n\n"
  else
    admin.update!(role: :admin)
    puts "  Administrator already present: #{admin.email_address}"
  end
end

# ---------------------------------------------------------------------------
# Standing pages
# ---------------------------------------------------------------------------
PAGE_CONTENT = {
  [ "about", "es" ] => {
    title: "Sobre mí",
    subtitle: "Médica psiquiatra. Acompaño procesos de desarrollo del ser.",
    body: <<~HTML
      <p>Soy médica psiquiatra. Durante años trabajé en consultorio acompañando a personas que llegaban con angustia, insomnio, agotamiento, y que de a poco empezaban a preguntarse algo más grande: para qué, hacia dónde, desde dónde vivo.</p>
      <p>Esa pregunta no se responde solo con medicación ni solo con meditación. Necesita las dos manos: la del rigor clínico y la de la práctica contemplativa. De ese cruce nació esta escuela.</p>
      <h2>Cómo trabajo</h2>
      <p>Enseño lo que practico. Nada de lo que vas a encontrar acá es una técnica que leí y transmití sin haberla habitado primero. Y nada llega sin pasar antes por el filtro de la evidencia.</p>
      <blockquote>No prometo bienestar. Ofrezco herramientas, tiempo y compañía para que puedas construirlo.</blockquote>
      <p><em>Reemplazá este texto desde el panel con tu propia historia.</em></p>
    HTML
  },
  [ "about", "en" ] => {
    title: "About me",
    subtitle: "Psychiatrist. I accompany processes of inner development.",
    body: <<~HTML
      <p>I am a psychiatrist. For years I worked with people who arrived carrying anxiety, insomnia and exhaustion, and who slowly began to ask something larger: what for, towards what, from where am I living.</p>
      <p>That question is not answered by medication alone, nor by meditation alone. It needs both hands: clinical rigour and contemplative practice. This school was born at that crossing.</p>
      <p><em>Replace this text from the admin panel with your own story.</em></p>
    HTML
  },
  [ "philosophy", "es" ] => {
    title: "La coherencia cuerpo-mente-espíritu",
    subtitle: "Por qué enseño lo que enseño, y desde dónde.",
    body: <<~HTML
      <p>El malestar rara vez vive en un solo lugar. Aparece como contractura y también como pensamiento repetido; como cansancio y también como pérdida de sentido. Tratarlo por partes suele dar alivio breve.</p>
      <h2>Tres puertas, un mismo cuarto</h2>
      <p><strong>El cuerpo</strong> es el primero en saber. Registra tensión, miedo y alegría mucho antes de que podamos nombrarlos. Trabajarlo es aprender a escuchar esa información temprana.</p>
      <p><strong>La mente</strong> organiza y también distorsiona. La atención plena no busca vaciarla: busca darnos un lugar desde donde mirarla sin quedar atrapados.</p>
      <p><strong>El espíritu</strong> es la pregunta por el sentido. No pide creer nada. Pide mirar con honestidad qué sostiene tu vida cuando todo lo demás tiembla.</p>
      <p>Coherencia es que estas tres dejen de contradecirse. Ese es todo el trabajo.</p>
      <p><em>Reemplazá este texto desde el panel.</em></p>
    HTML
  },
  [ "philosophy", "en" ] => {
    title: "Body-mind-spirit coherence",
    subtitle: "Why I teach what I teach, and where it comes from.",
    body: <<~HTML
      <p>Distress rarely lives in one place. It shows up as a tight shoulder and as a repeating thought; as fatigue and as a loss of meaning. Treating it in parts usually brings brief relief.</p>
      <p>Coherence is what happens when body, mind and spirit stop contradicting each other. That is the whole work.</p>
      <p><em>Replace this text from the admin panel.</em></p>
    HTML
  }
}.freeze

# The records always exist so the admin panel lists every page; the invented
# copy inside them is sample content.
Page::KEYS.product(I18n.available_locales.map(&:to_s)).each do |key, locale|
  page = Page.find_or_create_by!(key: key, locale: locale)
  attributes = PAGE_CONTENT[[ key, locale ]]

  # Only ever fill a page that is still blank; anything already written stays.
  next unless seed_samples && attributes && page.body.to_plain_text.blank?

  page.title = attributes[:title]
  page.subtitle = attributes[:subtitle]
  page.body = attributes[:body]
  page.save!
end
puts "  Standing pages: #{Page.count}#{" (empty, ready to write)" unless seed_samples}"

# ---------------------------------------------------------------------------
# Sample notes
# ---------------------------------------------------------------------------
ARTICLES = [
  {
    title: "Respirar no es relajarse",
    excerpt: "La respiración consciente no sirve para calmarse. Sirve para volver, y volver es otra cosa.",
    published_at: 12.days.ago,
    body: <<~HTML
      <p>Cuando alguien llega muy angustiado y le digo que respire, a veces me mira con desconfianza. Con razón: la indicación suena a consuelo vacío.</p>
      <p>Pero respirar conscientemente no es una técnica para relajarse. Es una manera de volver al único lugar donde algo puede pasar de verdad, que es acá.</p>
      <h2>Lo que cambia</h2>
      <p>La respiración es la única función autónoma que también podemos gobernar. Ese doble carácter la vuelve una puerta: por ahí entramos a un sistema que normalmente funciona sin nosotros.</p>
      <blockquote>No respirás para dejar de sentir. Respirás para poder sostener lo que estás sintiendo.</blockquote>
      <p>La diferencia parece sutil y lo cambia todo.</p>
    HTML
  },
  {
    title: "El insomnio como mensajero",
    excerpt: "Antes de tratarlo, vale la pena preguntarle qué vino a decir.",
    published_at: 26.days.ago,
    body: <<~HTML
      <p>El insomnio es uno de los motivos de consulta más frecuentes y también uno de los peor escuchados. Llega envuelto en un pedido claro: hacelo desaparecer.</p>
      <p>A veces corresponde. Pero muchas veces el insomnio no es la enfermedad, es el aviso.</p>
      <h2>Preguntas antes de la pastilla</h2>
      <ul>
        <li>¿A qué hora se apaga tu día de verdad?</li>
        <li>¿Qué aparece cuando se apaga la luz?</li>
        <li>¿Hay algo que no estás pudiendo pensar de día?</li>
      </ul>
      <p>No siempre hay respuesta inmediata. Pero hacer la pregunta ya cambia la relación con la noche.</p>
    HTML
  },
  {
    title: "Meditar cuando no podés meditar",
    excerpt: "Para quienes probaron, se frustraron y concluyeron que no es para ellos.",
    published_at: 45.days.ago,
    body: <<~HTML
      <p>La queja se repite: «lo intenté, no puedo, mi cabeza no para». Es la descripción más exacta posible de una mente humana.</p>
      <p>Meditar no es tener la mente en blanco. Es notar que se fue y volver. Esa vuelta, repetida, es la práctica entera.</p>
      <p>Si te distraés doscientas veces y volvés doscientas veces, meditaste doscientas veces.</p>
    HTML
  }
].freeze

if seed_samples
  ARTICLES.each do |attributes|
    article = Article.find_or_initialize_by(slug: attributes[:title].parameterize)
    next if article.persisted?

    article.assign_attributes(attributes.except(:body).merge(locale: "es"))
    article.body = attributes[:body]
    article.save!
  end
end
puts "  Notes: #{Article.count}"

# ---------------------------------------------------------------------------
# Sample courses
# ---------------------------------------------------------------------------
COURSES = [
  {
    title: "Introducción a la respiración",
    subtitle: "Tres prácticas breves para empezar hoy.",
    summary: "Un curso corto y sin costo para conocer la práctica antes de comprometerte con algo más largo.",
    modality: :on_demand,
    duration_label: "3 clases",
    price_cents: 0,
    status: :published,
    position: 0,
    description: <<~HTML,
      <p>Empezá por acá. Son tres encuentros breves, sin costo, para que veas si esta forma de trabajar te hace sentido antes de invertir tiempo o dinero en algo más largo.</p>
    HTML
    lessons: [
      { title: "Por qué respirar", summary: "De dónde sale que la respiración cambie algo.", duration_seconds: 420 },
      { title: "La respiración cuadrada", summary: "La práctica, paso a paso.", duration_seconds: 540 },
      { title: "Llevarlo al día", summary: "Cómo sostenerlo cuando no hay tiempo.", duration_seconds: 480 }
    ]
  },
  {
    title: "Fundamentos de atención plena",
    subtitle: "Ocho semanas para construir una práctica que se sostenga sola.",
    summary: "Un programa introductorio con base clínica: práctica guiada, marco teórico y seguimiento personal para instalar el hábito.",
    modality: :online_live,
    duration_label: "8 encuentros de 90 minutos",
    price_cents: 12_000_00,
    starts_on: 6.weeks.from_now.to_date,
    status: :published,
    position: 1,
    description: <<~HTML
      <p>Este curso está pensado para quien quiere empezar en serio y nunca encontró el modo. Trabajamos con prácticas breves y sostenidas, apoyadas en evidencia y adaptadas a una vida con obligaciones reales.</p>
      <h2>Qué vas a llevarte</h2>
      <ul>
        <li>Una práctica diaria de entre diez y veinte minutos, que puedas sostener.</li>
        <li>Herramientas para los momentos de crisis, no solo para los días buenos.</li>
        <li>Un marco para entender qué está pasando en tu cuerpo mientras practicás.</li>
      </ul>
    HTML
  },
  {
    title: "Habitar el cuerpo",
    subtitle: "Un ciclo breve sobre respiración, movimiento y descanso.",
    summary: "Cuatro encuentros para recuperar la señal del cuerpo antes de que se vuelva síntoma.",
    modality: :on_demand,
    duration_label: "4 clases grabadas",
    price_cents: 6_500_00,
    status: :published,
    position: 2,
    description: <<~HTML
      <p>El cuerpo avisa temprano y en voz baja. Este ciclo es un entrenamiento para escucharlo antes de que tenga que gritar.</p>
    HTML
  }
].freeze

if seed_samples
  COURSES.each do |attributes|
    course = Course.find_or_initialize_by(slug: attributes[:title].parameterize)
    next if course.persisted?

    course.assign_attributes(
      attributes.except(:description, :lessons).merge(locale: "es", currency: "ARS", published_at: Time.current)
    )
    course.description = attributes[:description]
    course.save!

    # A free course with no lessons cannot show what the student area does.
    attributes.fetch(:lessons, []).each_with_index do |lesson_attributes, index|
      lesson = course.lessons.find_or_initialize_by(slug: lesson_attributes[:title].parameterize)
      next if lesson.persisted?

      lesson.assign_attributes(lesson_attributes.merge(position: index + 1, published_at: Time.current))
      lesson.notes = "<p>Acá va el material de apoyo de la clase.</p>"
      lesson.save!
    end
  end
end
puts "  Courses: #{Course.count}"
puts "  Seed complete.\n\n"
