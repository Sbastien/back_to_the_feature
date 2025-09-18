Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"
  get "/register", to: "sessions#register"
  post "/register", to: "sessions#register_user"

  # Main dashboard
  root "flags#index"

  # Flag management routes (web interface)
  resources :flags do
    resources :rules, except: [ :show ]
  end

  # Group management routes
  resources :groups, except: [ :show ]

  # API routes
  namespace :api do
    namespace :v1 do
      resources :flags, except: [ :new, :edit ] do
        resources :rules, except: [ :new, :edit, :show ]
      end
      resources :groups, except: [ :new, :edit, :show ]
      get "/evaluate/:flag_name", to: "flags#evaluate"
      post "/evaluate/:flag_name", to: "flags#evaluate"
    end
  end

  # Admin routes
  namespace :admin do
    resources :users, only: [ :index, :update, :destroy ]
  end

  # Preferences routes
  patch "/preferences/theme", to: "preferences#update_theme"
  patch "/preferences/locale", to: "preferences#update_locale"
end
