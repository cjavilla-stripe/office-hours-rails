Rails.application.routes.draw do
  resources :orders
  resources :webhooks, only: [:create]

  root 'static_pages#root'
end
