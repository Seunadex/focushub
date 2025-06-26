Rails.application.routes.draw do
  devise_for :users
  # devise_scope :user do
  #   get "/login", to: "devise/sessions#new"
  #   get "/signup", to: "devise/registrations#new"
  #   post "/signup", to: "devise/registrations#create"
  # end
  get "/dashboard", to: "dashboard#show", as: :dashboard
  authenticated :user do
    root to: "dashboard#show", as: :authenticated_root
  end

  # Otherwise (guests), show the home landing page
  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
