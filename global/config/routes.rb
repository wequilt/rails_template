# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'graphql#public_execute'
  post '/graphql/admin', to: 'graphql#admin_execute'
end
