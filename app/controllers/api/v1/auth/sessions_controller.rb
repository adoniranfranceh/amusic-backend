class Api::V1::Auth::SessionsController < Api::V1::ApplicationController
  before_action :authorize_request, only: [ :logout ]

  def create
    user = User.find_by(email: login_params[:email])

    if user&.authenticate(login_params[:password])
      return generate_tokens_response(user:)
    end

    render json: { error: "Email ou senha inválidos" }, status: :unauthorized
  end

  def refresh
    refresh_token = params[:refresh_token]
    payload = JsonWebToken.decode(token: refresh_token)

    token_record = RefreshToken.find_by(jti: payload&.[](:jti), user_id: payload&.[](:user_id))

    if token_record&.active?
      token_record.update!(revoked: true)
      return generate_tokens_response(user: token_record.user)
    end

    render json: { error: "Refresh token inválido ou expirado" }, status: :unauthorized
  end

  def logout
    RefreshToken.where(user_id: current_user.id).update_all(revoked: true)
    head :no_content
  end

  private

  def generate_tokens_response(user:)
    access_token = JsonWebToken.encode(payload: { user_id: user.id })
    refresh_token = create_refresh_token(user)
    render json: { access_token:, refresh_token: }, status: :ok
  end

  def create_refresh_token(user)
    RefreshToken.create!(user:)
  end

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end
