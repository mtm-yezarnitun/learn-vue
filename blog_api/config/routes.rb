Rails.application.routes.draw do
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
      
      resources :posts do
        resources :comments, only: [:index, :create, :destroy]
      end
      resource :profile, only: [:show, :update] 
    end
  end

  namespace :admin do
    resources :users
  end
  
end
