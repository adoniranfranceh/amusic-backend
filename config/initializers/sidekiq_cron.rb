require 'sidekiq/cron/job'

Sidekiq::Cron::Job.create(
  name: 'Revoke old refresh tokens - every day at midnight',
  cron: '0 0 * * *',
  class: 'RevokeRefreshTokensJob'
)

