Rails.application.routes.draw do
  match '*path', to: 'application#handle_options_request', via: [:options]

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :filters, only: [:create, :show, :destroy, :update]
  resources :games, only: [:index, :show]
  # resources :sysreq_tokens, only: [:index, :show, :update]
  resources :tags, only: :index
  root to: 'games#index'
end
