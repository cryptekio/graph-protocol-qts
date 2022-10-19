Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/tests', to: 'graph_protocol/tests#create'
  get '/tests', to: 'graph_protocol/tests#index'
  get '/tests/:id', to: 'graph_protocol/tests#show'
  post '/tests/:id/run', to: 'graph_protocol/tests#run'

  get '/querysets', to: 'graph_protocol/query_set#index'
  post '/queryset', to: 'graph_protocol/query_set#create'

end
