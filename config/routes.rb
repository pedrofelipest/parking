Rails.application.routes.draw do
  resources :parkings, only: :index
  resources :parking, except: :index, :controller=>:parkings
  
  get "parking/:plate/plate", to: "parkings#plate"
  put "parking/:id/pay", to: "parkings#pay"
  put "parking/:id/out", to: "parkings#out"
  
end
