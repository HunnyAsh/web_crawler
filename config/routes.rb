Rails.application.routes.draw do
  resources :web_scrappers, only: [:index]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'web_scrappers#index'
end
