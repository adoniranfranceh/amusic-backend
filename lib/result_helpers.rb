module ResultHelpers
  def self.Success(value)
    { success: true, data: value  }
  end

  def self.Failure(message)
    { success: false, error: message  }
  end
end
