Rails.application.routes.draw do
  resources :games, only: [:index, :show]
  # resources :sysreq_tokens, only: [:index, :show, :update]
  resources :tags, only: :index
  root to: 'games#index'
end
