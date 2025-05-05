class RefreshToken < ApplicationRecord
  belongs_to :user

  before_validation :generate_defaults, on: :create

  validates :jti, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :revoked, inclusion: { in: [true, false] }

  def active?
    !revoked && Time.current < expires_at
  end

  private

  def generate_defaults
    self.jti ||= SecureRandom.uuid
    self.expires_at ||= 7.days.from_now
  end
end
