Rails.application.routes.draw do
  root "books#index"
  
  resources :users, only: [:new, :create, :show, :edit, :update, :destroy]
  resource :session, only: [:new, :create, :destroy]
  resources :read_histories, only: [:index, :show]
  resources :books, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  post 'guest_login', to: 'sessions#guest_login'
  delete '/logout' , to: 'sessions#destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
