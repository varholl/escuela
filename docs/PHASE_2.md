# Fase 2 — venta, suscripción y video

Este documento fija el diseño para que la fase 1 no cierre puertas. Nada de esto
está implementado todavía; lo que sí está hecho se marca como tal.

## El principio

**`Enrollment` es la única respuesta a «¿esta persona puede ver este curso?».**

Ya existe y ya se usa: hoy la otorgás a mano desde el panel. Cuando entren los
pagos, el webhook de la pasarela no inventa nada nuevo — crea exactamente el
mismo registro, con `source: "payment"` en vez de `"manual"`.

Eso significa que la lógica de acceso se escribe **una sola vez** y no depende de
qué pasarela terminemos eligiendo:

```ruby
def watchable_by?(user)
  user&.enrollments&.granting_access&.exists?(course: self)
end
```

## Lo que ya está listo

| Pieza | Estado |
|---|---|
| `Course` con precio (`price_cents`) y moneda | hecho |
| `Lesson` con `video_provider` + `video_reference` | hecho |
| `Enrollment` con `status`, `source`, `granted_at`, `expires_at` | hecho |
| Alta de alumnas por correo desde el panel (crea la cuenta) | hecho |
| Autenticación de usuarios (Rails 8) con rol `student` | hecho |

`video_provider` / `video_reference` es a propósito un par genérico: el primero
dice dónde vive el video (`active_storage`, `vimeo`, `mux`, `youtube`) y el
segundo guarda el identificador que ese proveedor necesita. Cambiar de hosting
no requiere migración.

## Lo que falta

### 1. Tablas nuevas

```ruby
# Qué se vende. Un curso suelto puede no tener plan; una membresía sí.
create_table :plans do |t|
  t.string  :name, null: false
  t.string  :slug, null: false
  t.integer :price_cents, null: false
  t.string  :currency, null: false, default: "ARS"
  t.integer :interval, null: false, default: 0   # one_time, monthly, yearly
  t.integer :status, null: false, default: 0     # draft, active, retired
  t.timestamps
end

# El vínculo recurrente con la alumna. Independiente de la pasarela.
create_table :subscriptions do |t|
  t.references :user, null: false, foreign_key: true
  t.references :plan, null: false, foreign_key: true
  t.integer    :status, null: false, default: 0  # pending, active, past_due, cancelled
  t.string     :provider, null: false            # "mercado_pago" | "stripe"
  t.string     :provider_reference, null: false  # id del lado de ellos
  t.datetime   :current_period_end
  t.datetime   :cancelled_at
  t.timestamps
  t.index [ :provider, :provider_reference ], unique: true
end

# Cada cobro, para conciliar y para no procesar dos veces el mismo webhook.
create_table :payments do |t|
  t.references :user, null: false, foreign_key: true
  t.references :subscription, foreign_key: true
  t.references :course, foreign_key: true
  t.integer    :amount_cents, null: false
  t.string     :currency, null: false
  t.integer    :status, null: false, default: 0  # pending, paid, failed, refunded
  t.string     :provider, null: false
  t.string     :provider_reference, null: false
  t.text       :payload                          # el webhook crudo, para auditar
  t.datetime   :paid_at
  t.timestamps
  t.index [ :provider, :provider_reference ], unique: true
end
```

El índice único sobre `[provider, provider_reference]` es lo que vuelve
**idempotentes** los webhooks: las pasarelas reintentan, y sin eso una alumna
podría quedar cobrada dos veces.

### 2. Un puerto, dos adaptadores

```
app/services/payments/
  gateway.rb              # la interfaz: checkout_url_for, verify_webhook, parse_event
  mercado_pago_gateway.rb
  stripe_gateway.rb
```

`Payments.gateway` devuelve el adaptador según `ENV["PAYMENT_PROVIDER"]`. Los
controladores nunca nombran a Mercado Pago ni a Stripe.

Cada adaptador traduce el evento del proveedor a un puñado de eventos propios
(`payment_succeeded`, `subscription_renewed`, `subscription_cancelled`) y un
único objeto de dominio decide qué hacer con ellos.

**Para elegir:** Mercado Pago si las alumnas son de Argentina (pesos, tarjetas
locales, cuotas); Stripe si cobra en dólares a alumnas de afuera. Se puede
empezar con uno y agregar el otro sin tocar el resto de la aplicación.

### 3. Video

Hoy `Lesson` puede guardar el archivo con Active Storage, que sirve para probar
pero **no para vender**: un archivo servido desde el volumen se descarga y se
comparte sin control, y llenaría el disco de Fly.

Recomendación al llegar acá: **Mux** o **Vimeo**, con URLs firmadas de corta
duración generadas en el servidor sólo si `Enrollment#grants_access?`. El
esquema ya lo soporta: `video_provider: "mux"`, `video_reference: <playback_id>`.

### 4. Área de alumnas

- `/mis-cursos` — lo que compró
- `/cursos/:slug/clases/:slug` — el reproductor, detrás de la verificación
- Registro público (hoy las cuentas sólo se crean desde el panel)
- Correo de bienvenida con el enlace para elegir contraseña

### 5. Facturación

Argentina requiere factura electrónica. Suele resolverse con un servicio externo
(Facturante, TusFacturasAPP) disparado desde el mismo lugar que crea el
`Payment`. Conviene confirmarlo con la contadora antes de escribir código.

## Orden sugerido

1. Registro público y área de alumnas, con accesos todavía otorgados a mano.
   Ya se puede vender por transferencia y dar el acceso a dedo.
2. Elegir hosting de video y poner el reproductor detrás de `Enrollment`.
3. Recién entonces enchufar la pasarela: para ese momento sólo falta que el
   webhook cree el `Enrollment` que ya sabés otorgar a mano.

Ese orden permite cobrar desde el primer paso y deja lo irreversible para el
final.
