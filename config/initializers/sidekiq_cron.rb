require "sidekiq/cron/job"

Sidekiq::Cron::Job.create(
  name: "Clear old refresh tokens - every day at midnight",
  cron: "0 0 * * *",
  class: "ClearOldRefreshTokensJob"
)
