Rails.application.routes.draw do
  get  "sign-in", to: "sessions#new", as: :sign_in
  post "sign-in", to: "sessions#create"
  get  "sign-up", to: "registrations#new", as: :sign_up
  post "sign-up", to: "registrations#create"
  resources :sessions, only: [ :index, :show, :destroy ]
  resource  :password, only: [ :edit, :update ]
  namespace :identity do
    resource :email,              only: [ :edit, :update ]
    resource :password_reset,     only: [ :new, :edit, :create, :update ], path: "password-reset"
  end
  get "account", to: "home#index"
  get "account/work-schedule", to: "work_schedules#edit", as: :edit_work_schedule
  patch "account/work-schedule", to: "work_schedules#update", as: :work_schedule
  root "time_entries#index"
  resources :time_entries, only: [ :index, :show, :new, :create, :edit, :update, :destroy ], path: "time-entries" do
    member do
      post :start_break
      patch :end_break
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
