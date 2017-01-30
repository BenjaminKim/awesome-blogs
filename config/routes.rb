Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :feeds, defaults: { format: :xml }
  resources :categories
end
