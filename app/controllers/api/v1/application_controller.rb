class Api::V1::ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    token = request.headers["Authorization"]&.split(" ")&.last
    return render_unauthorized if token.nil?

    decoded = JsonWebToken.decode(token: token)
    return render_unauthorized if decoded.nil?

    @current_user = User.find_by(id: decoded[:user_id])
    render render_unauthorized if @current_user.nil?
  rescue JWT::DecodeError => e
    render_unauthorized
  end

  def render_unauthorized
    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
