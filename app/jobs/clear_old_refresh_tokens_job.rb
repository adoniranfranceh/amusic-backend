class ClearOldRefreshTokensJob < ApplicationJob
  queue_as :default

  def perform
    RefreshToken.where("revoked = true AND updated_at < ?", 30.days.ago)
                .in_batches(of: 1000)
                .delete_all
  end
end
