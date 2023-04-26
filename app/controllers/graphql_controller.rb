# frozen_string_literal: true

class GraphqlController < ApplicationController
  attr_reader :current_user

  before_action :authenticate_user

  rescue_from StandardError, with: :handle_error

  def execute
    render json: Schema.execute(query, variables:, context:, operation_name:)
  end

  def context
    { current_user: }
  end

  def operation_name
    params[:operationName]
  end

  def query
    params[:query]
  end

  def variables
    case raw_vars
    when String then raw_vars.present? ? JSON.parse(raw_vars) || {} : {}
    when ActionController::Parameters then raw_vars.to_unsafe_hash
    when nil then {}
    else raise ArgumentError, "Unexpected parameter: #{raw_vars}"
    end
  end

  private

  def authenticate_user
    if (header = request.headers['X-Authenticated-User'])
      auth_context = JSON.parse(Base64.decode64(header))
      @current_user = User.new(auth_context.deep_transform_keys(&:underscore)) if auth_context
    end
  rescue ArgumentError, JSON::ParserError
    nil
  end

  def raw_vars
    @raw_vars ||= params[:variables]
  end

  def handle_error_in_development(err)
    logger.error(err.message)
    logger.error(err.backtrace.join("\n"))

    render exception_json(err)
  end

  def exception_json(err)
    {
      json: {
        errors: [{ message: err.message, backtrace: err.backtrace }],
        data: {}
      },
      status: :internal_server_error
    }
  end

  def handle_error(exception)
    raise exception unless Rails.env.development?

    handle_error_in_development(exception)
  end
end
