require 'rails_helper'

RSpec.describe ClearOldRefreshTokensJob, type: :job do
  it 'deletes the old and revoked tokens' do
    user = User.create(email: 'x@x.com', password: '123456')
    RefreshToken.create!(user:, revoked: true, updated_at: 31.days.ago)
    RefreshToken.create!(user:, revoked: true, updated_at: 29.days.ago)
    RefreshToken.create!(user:, revoked: false, updated_at: 31.days.ago)

    expect {
      described_class.perform_now
    }.to change(RefreshToken, :count).by(-1)
  end
end
