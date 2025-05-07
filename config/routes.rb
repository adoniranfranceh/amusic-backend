require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#logout"
        post "refresh", to: "sessions#refresh"
        get "me", to: "sessions#me"
      end
    end
  end
end
