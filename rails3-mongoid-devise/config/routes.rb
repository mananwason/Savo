Rails3MongoidDevise::Application.routes.draw do
  authenticated :user do
    root :to => 'home#myTrips'
  end
  
  root :to => "home#myTrips"

  get 'users/signin' => "home#myTrips"
  get 'users/signup' => "home#myTrips"

  get 'rewards' => "home#rewards"

  get 'myTrips' => "home#myTrips"

  get 'settings' => "home#settings"

  get 'help' => "home#help"

  get 'newTrip' => "home#newTrip"

  post 'storeTripDetails' => "home#storeTripDetails"
  
  post 'updateRewardPoints' => "home#updateRewardPoints"
  get 'updateRewardPoints' => "home#rewards"

  get 'settings' => "home#settings"

  post 'updateSettings' => "home#updateSettings"

  match 'fetchTripBookingDetails' => "home#fetchTripBookingDetails", via: [:get, :post]

  devise_for :users
  resources :users
end