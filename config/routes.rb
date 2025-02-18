Rails.application.routes.draw do
  root "air_quality#index"
  get "air_quality", to: "air_quality#index"
end
