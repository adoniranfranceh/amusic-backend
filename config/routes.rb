Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#logout"
        post "refresh", to: "sessions#refresh"
      end
    end
  end
end
