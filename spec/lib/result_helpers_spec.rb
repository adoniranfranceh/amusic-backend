require 'rails_helper'

RSpec.describe ResultHelpers do
  describe '.Success' do
    it 'returns a success hash with data' do
      result = described_class.Success({ token: 'abc' })
      expect(result).to eq({ success: true, data: { token: 'abc' } })
    end
  end

  describe '.Failure' do
    it 'returns a failure hash with an error message' do
      result = described_class.Failure('invalid')
      expect(result).to eq({ success: false, error: 'invalid' })
    end
  end
end
