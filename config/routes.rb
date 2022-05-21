Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
  }

  resources :posts
  resources :comments, only: [:create, :update, :destroy]

  resources :posts do
    resources :comments, only: [:create, :update, :destroy]
  end

  get "/users/:id", to: "users#show", as: "user"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  root "posts#index"

end
