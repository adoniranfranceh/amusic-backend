class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base

  def self.encode(payload:, exp: 15.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token:)
    body = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" }).first
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end
end
