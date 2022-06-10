Rails.application.routes.draw do

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :users, only: :show do
    get 'posts'
    get 'friends'
    get 'likes'
  end

  resources :posts
  resources :comments, only: [:create, :update, :destroy]
  resources :likes, only: [:create, :destroy]

  resources :posts do
    resources :comments, only: [:create, :update, :destroy]
  end

  get '/friends', to: 'users#friends', as: :friends
  scope '/friends', as: :friends do
    get 'find', to: 'users#find_friends'
    get 'requests', to: 'users#friend_requests'
  end

  resources :friend_requests, only: :create do
    member do
      get 'confirm'
      post 'confirm'
      delete 'delete'
    end
  end

  delete 'unfriend', to: 'friendships#destroy', as: 'destroy_friendship'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  root "posts#index"

end
