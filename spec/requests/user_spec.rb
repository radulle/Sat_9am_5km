# frozen_string_literal: true

RSpec.describe '/user' do
  let(:user) { create(:user, with_avatar: true) }

  describe 'GET /user/sign_up' do
    it 'renders successful response' do
      get new_user_registration_url
      expect(response).to redirect_to 'https://t.me/sat9am5kmbot'
    end
  end

  describe 'POST /user/login' do
    it 'redirects to root page after successful login' do
      post user_session_url, params: { user: { email: user.email, password: user.password } }
      expect(response).to redirect_to root_path
    end
  end

  context 'with authenticated user' do
    before do
      sign_in user
      Bullet.n_plus_one_query_enable = false if defined?(Bullet)
    end

    after do
      Bullet.n_plus_one_query_enable = true if defined?(Bullet)
    end

    describe 'GET /user' do
      before { get user_url }

      it { expect(response).to be_successful }
    end

    describe 'GET /user/edit' do
      before { get edit_user_url }

      it { expect(response).to be_successful }
    end

    describe 'POST /user' do
      it 'updates user attributes' do
        expect { patch user_url, params: { user: { first_name: 'Tester' } } }
          .to change(user, :first_name).to('Tester')

        expect(CompressUserImageJob).to have_been_enqueued
        expect(response).to redirect_to user_path
      end

      it 'does not enqueued job to compress image' do
        patch user_url, params: { delete_image: '1', user: user.attributes.slice('first_name', 'last_name') }
        expect(CompressUserImageJob).not_to have_been_enqueued
        expect(response).to redirect_to user_path
      end
    end
  end
end
