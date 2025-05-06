require 'rails_helper'

RSpec.describe Auth::TokenGenerator do
  let(:user) { User.create!(email: 'x@x.com', password: '123456') }

  describe '.call' do
    it 'returns a hash with access and refresh tokens' do
      result = described_class.call(user)

      expect(result).to include(:access_token, :refresh_token)
      expect(result[:access_token]).to be_a(String)
      expect(result[:refresh_token]).to be_a(String)
    end

    it 'revokes previous refresh tokens for the user' do
      old_token = RefreshToken.create!(user: user, revoked: false)
      described_class.call(user)

      old_token.reload
      expect(old_token.revoked).to be true
    end

    it 'creates a new refresh token for the user' do
      expect {
        described_class.call(user)
      }.to change { RefreshToken.where(user: user).count }.by(1)
    end
  end
end
