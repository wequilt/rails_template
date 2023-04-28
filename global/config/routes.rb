# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'
  get '/health', to: proc { [200, {}, ['success']] }
end
