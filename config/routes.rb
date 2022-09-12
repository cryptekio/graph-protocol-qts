Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/tests', to: 'graph_protocol/tests#create'
  get '/tests', to: 'graph_protocol/tests#index'
  get '/tests/:uuid', to: 'graph_protocol/tests#show'

  get '/querysets', to: 'graph_protocol/query_sets#index'
end
