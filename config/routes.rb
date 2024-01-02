Rails.application.routes.draw do
  scope defaults: { format: :xml } do
    root 'feeds#index'
  end
end