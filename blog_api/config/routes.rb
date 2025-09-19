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
      resources :posts do
        resources :comments, only: [:index, :create, :destroy]
      end
    end
  end
  
end
