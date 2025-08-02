Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#index"

  get "/dashboard", to: "pages#index"
  get "/unconfirmed", to: "pages#unconfirmed"
  get "/pending_approval", to: "pages#pending_approval"
  get "/transactions/buy", to: "transactions#buy"
  get "/transactions/sell", to: "transactions#sell"

  resources :portfolios
  resources :transactions do
    collection do
      get :fetch_price
    end
  end

  match "*unmatched", to: "errors#not_found", via: :all

  # Admin namespace routes
  namespace :admin do
    root "dashboard#index"
    get "/dashboard", to: "dashboard#index"

    resources :traders do
      member do
        patch :approve
        patch :reject
      end
    end

    get "/pending_traders", to: "traders#pending", as: :pending_traders
    resources :transactions, only: [ :index, :show ]

    match "*path", to: "dashboard#not_found", via: :all
  end
end
