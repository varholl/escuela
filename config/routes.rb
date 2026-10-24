Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "robots.txt" => "robots#show", format: :text, as: :robots

  # Error pages, reached through config.exceptions_app rather than by linking.
  match "/404", to: "errors#not_found",      via: :all
  match "/422", to: "errors#unprocessable",  via: :all
  match "/500", to: "errors#server_error",   via: :all

  # Authentication and the admin panel live outside the locale scope: they are
  # back-office screens for the owner, always rendered in the default locale.
  resource :session, only: %i[ new create destroy ]

  # OmniAuth mounts /auth/google_oauth2 itself; this is only the way back.
  get "auth/google_oauth2/callback" => "omniauth_callbacks#google_oauth2", as: :google_callback
  get "auth/failure" => "omniauth_callbacks#failure"
  resources :passwords, param: :token, only: %i[ new create edit update ]

  namespace :admin do
    root "dashboard#show"

    resource :account, only: %i[ edit update ]

    resources :articles
    resources :courses do
      resources :lessons, except: :show
      resources :enrollments, only: %i[ index new create destroy ]
    end
    resources :pages, only: %i[ index edit update ]
    resources :inquiries, only: %i[ index show destroy ] do
      resource :handling, only: %i[ create destroy ], module: :inquiries
    end
    resources :users, only: %i[ index show ] do
      resource :deactivation, only: %i[ create destroy ], module: :users
      resources :enrollments, only: :create, module: :users
    end
  end

  # The public site. Spanish is served from the bare path (/cursos) and English
  # from an /en prefix (/en/cursos); see ApplicationController#default_url_options.
  #
  # Because :locale is an optional leading segment, a single positional argument
  # binds to it rather than to :id. Always name the key on these helpers:
  #   course_path(id: course)   NOT   course_path(course)
  scope "(:locale)", locale: /es/ do
    get "sobre-mi"  => "pages#about",      as: :about
    get "filosofia" => "pages#philosophy", as: :philosophy
    get "privacidad" => "pages#privacy", as: :privacy
    get "terminos" => "pages#terms", as: :terms

    # The institutional video, public but still served from the private bucket.
    get "video/:id" => "page_videos#show", as: :page_video,
      constraints: { id: Regexp.union(Page::KEYS) }

    resource :registration, path: "registro", only: %i[ new create ]
    get "mis-cursos" => "library#show", as: :library

    # One controller, two sections; `kind` tells it which. Link to a single
    # piece through ArticlesHelper#article_path_for, which picks the right one.
    { reflections: [ "reflexiones", "reflection" ], notes: [ "apuntes", "note" ] }.each do |name, (path, kind)|
      resources name, path: path, controller: "articles", only: %i[ index show ], defaults: { kind: kind } do
        # The picture a link preview shows. Served through the app so its address
        # can outlive Active Storage's five-minute URLs.
        get :portada, on: :member, to: "article_covers#show", as: :cover
      end
    end

    # The reflections were called "notas" until 2026-10, and those links are
    # out there in WhatsApp chats. Anything under the old path, the cover
    # included, moves to the same place under the new one.
    get "notas(/*rest)", to: redirect { |_, request| request.path.sub(%r{/notas(?=/|\z)}, "/reflexiones") }

    resources :courses, path: "cursos", only: %i[ index show ] do
      resource :enrollment, only: :create
      resources :lessons, path: "clases", only: :show do
        # The video is fetched through the app so the gate applies to the bytes
        # too, not only to the page around them.
        get :video, on: :member, to: "lesson_videos#show"
      end
    end

    resource :inquiry, path: "contacto", only: %i[ new create ], as: :contact

    root "pages#home"
  end
end
