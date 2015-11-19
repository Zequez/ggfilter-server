Rails.application.routes.draw do
  resources :games
  resources :tags, only: :index
  root to: 'games#index'
end
