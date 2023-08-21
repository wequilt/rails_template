# frozen_string_literal: true

module Admin
  module Types
    class Viewer < Shared::Types::Base
      description 'The currently logged in admin user'

      key fields: :id
      global_id_field :id, shareable: true

      field :email, String, 'The email address of the currently logged in admin user', null: true, shareable: true
    end
  end
end
