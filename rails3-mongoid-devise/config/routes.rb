Rails3MongoidDevise::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  
  root :to => "home#index"

  get 'rewards' => "home#rewards"

  get 'myTrips' => "home#myTrips"

  get 'settings' => "home#settings"

  get 'newTrip' => "home#newTrip"

  post 'storeTripDetails' => "home#storeTripDetails"
  
  post 'updateRewardPoints' => "home#updateRewardPoints"

  get 'settings' => "home#settings"

  post 'updateSettings' => "home#updateSettings"

  match 'fetchTripBookingDetails' => "home#fetchTripBookingDetails", via: [:get, :post]
  
  devise_for :users
  resources :users
end