class Api::V1::ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    token = request.headers["Authorization"]&.split(" ")&.last
    decoded = JsonWebToken.decode(token:)

    if decoded.present?
      @current_user = User.find_by(id: decoded[:user_id])
      render_unauthorized unless @current_user
    else
      render_unauthorized
    end
  end

  def render_unauthorized
    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
