class Api::V1::Auth::SessionsController < Api::V1::ApplicationController
  def create
    user = User.find_by(email: login_params[:email])

    if user&.authenticate(login_params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      return render json: build_auth_response(user:, token:), status: :ok
    end

    render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
  end

  private

  def build_auth_response(user:, token:)
    { user: user.slice(:id, :email), token: }
  end

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end
