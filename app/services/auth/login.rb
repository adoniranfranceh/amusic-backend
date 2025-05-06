module Auth
  class Login
    extend ResultHelpers

    def self.call(auth_params)
      return ResultHelpers.Failure("Email e senha são obrigatórios") if auth_params.blank? || auth_params[:email].blank? || auth_params[:password].blank?

      user = User.find_by(email: auth_params[:email])
      return ResultHelpers.Failure("Email ou senha inválidos") unless user&.authenticate(auth_params[:password])

      ResultHelpers.Success(TokenGenerator.call(user))
    end
  end
end
