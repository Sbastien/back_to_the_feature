class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # TODO: Implement API key authentication for production
  # before_action :authenticate_api_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def authenticate_api_user!
    authenticate_user!
  end

  def not_found(exception)
    render json: { error: "Not found", message: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { error: "Validation failed", message: exception.message }, status: :unprocessable_entity
  end
end