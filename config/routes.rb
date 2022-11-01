require_dependency "annotator_constraint"

Rails.application.routes.draw do

  get '/annotator/codes', to: 'annotator/discourse_annotator/codes#index', format: :json,
      constraints: lambda { |req| DiscourseAnnotator::Setting.instance.public_codes_list_api_endpoint? }


  namespace :annotator, constraints: AnnotatorConstraint.new do

    root to: 'application#front'
    resources :topics, only: [:index, :show]
    resources :videos, only: [:show]

    namespace :discourse_annotator, path: '' do
      resources :codes do
        collection do
          post :update_parent
        end
        member do
          get :merge
          put :merge_into
          put :copy
          get :tree_item, constraints: { format: :json }
        end
      end
      match 'localized_codes', to: 'localized_codes#index', via: [:get], defaults: { format: :json }, constraints: { format: :json }
      match 'mergeable_codes', to: 'localized_codes#mergeable', via: [:get], defaults: { format: :json }, constraints: { format: :json }
      match 'autosuggest_codes', to: 'localized_codes#autosuggest_codes', via: [:get], defaults: { format: :json }, constraints: { format: :json }
      resources :localized_codes, only: [:show]
      resources :code_names
      resources :languages
      resources :user_settings
      resource :setting, only: [:show, :edit, :update], path: 'settings'
      # Search
      match 'search', to: 'pages#search', via: [:get], defaults: { format: :json }, constraints: { format: :json }
      match 'search', to: 'annotations#options', via: [:options], defaults: { format: :json }, constraints: { format: :json }

      # Annotations Endpoint
      resources :annotations, only: [:index, :show], defaults: { format: :html }, constraints: { format: :html } do
        collection do
          post :update_code
          delete :bulk_destroy
        end
      end
      resources :annotations, only: [:index, :create, :show, :edit, :update, :destroy], defaults: { format: :json }, constraints: { format: :json } do
        match '/', to: 'annotations#options', via: [:options], on: :collection
        match '/', to: 'annotations#options', via: [:options], on: :member
      end
      resources :text_annotations, only: [:index, :show, :edit, :update, :destroy]
      resources :video_annotations, only: [:index, :show, :edit, :update, :destroy]
      resources :image_annotations, only: [:index, :show, :edit, :update, :destroy]
    end
  end

end
