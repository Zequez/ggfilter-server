Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  resources :games, only: [:index, :show]
  # resources :sysreq_tokens, only: [:index, :show, :update]
  resources :tags, only: :index
  root to: 'games#index'
end
