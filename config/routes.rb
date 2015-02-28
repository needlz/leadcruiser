Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'reports#index'
  # root 'visitors#home'
  
  resources :reports, only: :index
  resources :clicks_reports, only: :index

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'reports/refresh', :to => 'reports#refresh'
  get 'clicks_reports/:clients_vertical_id/by_client', :to => 'clicks_reports#by_client', :as => 'clicks_reports_by_client'
  namespace :api do
    namespace :v1 do
      with_options only: :create do |option|
        option.resources :leads
        option.resources :visitors
        option.resources :clicks
        option.resources :clients
      end
    end
  end

  post '/admin/resend_lead', :to => 'admins#resend_lead', :as => 'resend_lead'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
