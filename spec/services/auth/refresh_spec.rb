require 'rails_helper'

RSpec.describe Auth::Refresh do
  let(:user) { User.create!(email: 'x@x.com', password: '123456') }

  it 'returns a new access token if the refresh token is valid' do
    refresh_token = RefreshToken.create(user:)
    refresh_token_jwt = JsonWebToken.encode(payload: { jti: refresh_token.jti, user_id: user.id })
    result = Auth::Refresh.call(refresh_token_jwt)

    expect(result[:success]).to be true
    expect(result[:data]).to include(:access_token, :refresh_token)
  end

  it 'returns an error if the token is invalid' do
    result = described_class.call('invalid.token')

    expect(result[:success]).to be false
    expect(result[:error]).to eq('Refresh token inválido ou expirado')
  end
end
