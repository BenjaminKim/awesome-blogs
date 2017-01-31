Rails.application.routes.draw do
  scope defaults: { format: :xml } do
    root 'feeds#index'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    resources :feeds
  end
end
