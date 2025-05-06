require 'rails_helper'

RSpec.describe 'Api::V1::Auth::SessionsController', type: :request do
  let(:user) { User.create!(email: 'x@x.com', password: '123456') }
  let(:headers) { { 'Content-Type': 'application/json' } }

  describe 'POST /api/v1/auth/login' do
    context 'with valid credentials' do
      it 'returns access and refresh tokens' do
        post '/api/v1/auth/login', params: {
          auth: { email: user.email, password: '123456' }
        }.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['access_token']).to be_present
        expect(json['refresh_token']).to be_present

        expect(json['refresh_token']).to be_a(String)
      end
    end

    context 'with incorrect email' do
      it 'returns unauthorized status and error message' do
        post '/api/v1/auth/login', params: {
          auth: { email: 'wrong@email.com', password: '123456' }
        }.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Email ou senha inválidos')
      end
    end

    context 'with incorrect password' do
      it 'returns unauthorized status and error message' do
        post '/api/v1/auth/login', params: {
          auth: { email: user.email, password: 'wrongpass' }
        }.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Email ou senha inválidos')
      end
    end

    context 'with missing params' do
      it 'returns bad request status and validation error message' do
        post '/api/v1/auth/login', params: {}.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Email e senha são obrigatórios')
      end
    end
  end

  describe 'POST /api/v1/auth/refresh' do
    let!(:refresh_token_record) { RefreshToken.create!(user: user, revoked: false) }
    let(:refresh_token) do
      JsonWebToken.encode(payload: { user_id: user.id, jti: refresh_token_record.jti }, exp: 2.hours.from_now)
    end

    context 'with valid refresh token' do
      it 'revokes old token and issues new tokens' do
        post '/api/v1/auth/refresh', params: {
          refresh_token: refresh_token
        }.to_json, headers: headers

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['access_token']).to be_present
        expect(json['refresh_token']).to be_present
      end
    end

    context 'with expired refresh token' do
      let(:expired_token) do
        JsonWebToken.encode(payload: { user_id: user.id, jti: refresh_token_record.jti }, exp: 1.hour.ago)
      end

      it 'returns unauthorized and error message' do
        post '/api/v1/auth/refresh', params: {
          refresh_token: expired_token
        }.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Refresh token inválido ou expirado')
      end
    end

    context 'with malformed token' do
      it 'returns unauthorized' do
        post '/api/v1/auth/refresh', params: {
          refresh_token: 'not.a.token'
        }.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    let!(:refresh_token_record) { RefreshToken.create(user: user) }
    let(:access_token) { JsonWebToken.encode(payload: { user_id: user.id }) }

    context 'with valid access token' do
      it 'revokes all refresh tokens' do
        delete '/api/v1/auth/logout', headers: headers.merge('Authorization' => "Bearer #{access_token}")
        expect(response).to have_http_status(:no_content)
        expect(refresh_token_record.reload.revoked).to be true
      end
    end

    context 'with missing access token' do
      it 'returns unauthorized' do
        delete '/api/v1/auth/logout', headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with expired access token' do
      let(:expired_token) { JsonWebToken.encode(payload: { user_id: user.id }, exp: 1.minute.ago) }

      it 'returns unauthorized' do
        delete '/api/v1/auth/logout', headers: headers.merge('Authorization' => "Bearer #{expired_token}")
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:access_token) { JsonWebToken.encode(payload: { user_id: user.id }) }

    context 'with valid access token' do
      it 'returns current user data' do
        get '/api/v1/auth/me', headers: headers.merge('Authorization' => "Bearer #{access_token}")

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['email']).to eq(user.email)
        expect(json['id']).to eq(user.id)
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        get '/api/v1/auth/me', headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
