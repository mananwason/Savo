Rails3MongoidDevise::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"

  get 'rewards' => "home#rewards"

  get 'myTrips' => "home#myTrips"

  post 'updateRewardPoints' => "home#updateRewardPoints"

  devise_for :users
  resources :users
end