Rails.application.routes.draw do
  scope defaults: { format: :xml } do
    root 'feeds#index'
    resources :feeds do
      scope defaults: { format: :json } do
      end
    end
  end
end