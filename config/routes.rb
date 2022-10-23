Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/tests', to: 'graph_protocol/tests#create'
  get '/tests', to: 'graph_protocol/tests#index'
  get '/tests/:id', to: 'graph_protocol/tests#show'
  post '/tests/:id/run', to: 'graph_protocol/tests#run'
  delete '/tests/:id', to: 'graph_protocol/tests#delete'
  get '/tests/:id/instance/:iid', to: 'graph_protocol/tests#show_instance'
  post '/tests/:id/instance/:iid/stop', to: 'graph_protocol/tests#cancel_instance'

  get '/querysets', to: 'graph_protocol/query_set#index'
  get '/querysets/:id', to: 'graph_protocol/query_set#show'
  post '/querysets', to: 'graph_protocol/query_set#create'
  post '/querysets/:id/reimport', to: 'graph_protocol/query_set#reimport'
  delete '/querysets/:id', to: 'graph_protocol/query_set#delete'

end
