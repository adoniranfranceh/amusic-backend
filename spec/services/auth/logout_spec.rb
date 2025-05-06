require 'rails_helper'

RSpec.describe Auth::Logout do
  let(:user) { User.create!(email: 'x@x.com', password: '123456') }

  before do
    RefreshToken.create!(user: user, revoked: false)
    RefreshToken.create!(user: user, revoked: false)
    RefreshToken.create!(user: user, revoked: true)
  end

  describe '.call' do
    it 'revokes all refresh tokens for the user' do
      expect {
        described_class.call(user)
      }.to change { RefreshToken.where(user: user, revoked: false).count }.from(2).to(0)

      expect(RefreshToken.where(user: user, revoked: true).count).to eq(3)
    end
  end
end
