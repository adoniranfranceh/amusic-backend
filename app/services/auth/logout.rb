module Auth
  class Logout
    def self.call(user)
      RefreshToken.where(user_id: user.id).update_all(revoked: true)
    end
  end
end
