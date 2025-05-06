module Auth
  class Refresh
    extend ResultHelpers

    def self.call(token)
      return ResultHelpers.Failure("Refresh token não fornecido") if token.blank?

      RefreshToken.where(revoked: true).where('updated_at < ?', 7.days.ago).delete_all

      payload = JsonWebToken.decode(token: token)
      return ResultHelpers.Failure("Refresh token inválido ou expirado") if payload.nil?

      token_record = RefreshToken.find_by(jti: payload[:jti], user_id: payload[:user_id])
      return ResultHelpers.Failure("Refresh inexistente") unless token_record&.active?

      token_record.update!(revoked: true)
      ResultHelpers.Success(TokenGenerator.call(token_record.user))
    end
  end
end
