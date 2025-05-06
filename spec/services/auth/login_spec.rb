require 'rails_helper'

RSpec.describe Auth::Login do
  let!(:user) { User.create!(email: 'x@x.com', password: '123456') }

  context 'with valid credentials' do
    it 'returns a success result with tokens' do
      result = described_class.call({ email: user.email, password: '123456' })

      expect(result[:success]).to be true
      expect(result[:data]).to include(:access_token, :refresh_token)
    end
  end

  context 'with invalid password' do
    it 'returns a failure result' do
      result = described_class.call({ email: user.email, password: 'wrong' })

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Email ou senha inválidos')
    end
  end

  context 'with non-existent email' do
    it 'returns a failure result' do
      result = described_class.call({ email: 'unknown@example.com', password: '123456' })

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Email ou senha inválidos')
    end
  end
end
