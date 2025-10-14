Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  devise_for :users,
             defaults: { format: :json },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             },
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             }
  namespace :api do
    namespace :v1 do
      post 'google_login', to: 'google_auth#login'

      get 'google_login', to: 'google_auth#redirect'
      get 'google_callback', to: 'google_auth#callback'

      get '/calendar/events', to: 'calendar#events'
      get 'calendar/cached_events', to: 'calendar#cached_events'
      post '/calendar/events', to: 'calendar#create_event'
      patch '/calendar/events/:id', to: 'calendar#update'
      delete '/calendar/events/:id', to: 'calendar#destroy'

      get '/calendar/export_pdf', to: 'calendar#export_pdf'
      get '/calendar/export_csv', to: 'calendar#export_csv'
      post '/calendar/import_csv', to: 'calendar#import_csv'
      get '/calendar/download_template', to: 'calendar#download_template'
      
      resources :posts do
        resources :comments, only: %i[index create destroy]
      end
      resource :profile, only: %i[show update]
    end
  end

  namespace :admin do
    resources :users
  end

  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
    mount LetterOpenerWeb::Engine, at: '/mailbox'
  end
end
