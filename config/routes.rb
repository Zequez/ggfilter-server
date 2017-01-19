Rails.application.routes.draw do
  match '*path', to: 'application#handle_options_request', via: [:options]

  # devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, path: 'auth', controllers: { sessions: 'sessions' }
  devise_scope :user do
    get 'auth/current_user', to: 'sessions#show'
  end

  # resources :filters
  resources :games, only: [:index, :show]
  # resources :sysreq_tokens, only: [:index, :show, :update]
  resources :tags, only: :index
  resources :scrap_logs, only: :index

  get '*path', to: 'app#index'

  root to: 'app#index'
end
