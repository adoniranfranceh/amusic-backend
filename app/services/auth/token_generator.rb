module Auth
  class TokenGenerator
    def self.call(user)
      access_token = JsonWebToken.encode(payload: { user_id: user.id }, exp: 1.hour.from_now)

      RefreshToken.where(user_id: user.id, revoked: false).update_all(revoked: true)
      refresh_token = RefreshToken.create!(user: user)

      refresh_token_jwt = JsonWebToken.encode(payload: {
        jti: refresh_token.jti,
        user_id: user.id
      })

      {
        access_token: access_token,
        refresh_token: refresh_token_jwt
      }
    end
  end
end
