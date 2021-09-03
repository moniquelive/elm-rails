Rails.application.routes.draw do
  resources :pokemons
  resources :indices

  root 'indices#index'
end
