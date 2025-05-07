class Api::V1::Auth::SessionsController < Api::V1::ApplicationController
  before_action :authorize_request, only: %i[logout me]

  def create
    result = Auth::Login.call(login_params)

    if result[:success]
      render json: result[:data], status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  def refresh
    result = Auth::Refresh.call(params[:refresh_token])

    if result[:success]
      render json: result[:data], status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  def logout
    Auth::Logout.call(current_user)
    head :no_content
  end

  def me
    render json: {
      id: current_user.id,
      email: current_user.email
    }, status: :ok
  end

  private

  def login_params
    params.fetch(:auth, {}).permit(:email, :password)
  end
end
