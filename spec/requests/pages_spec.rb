require 'rails_helper'

RSpec.describe "Pages", type: :request do
  let!(:user) { User.create(first_name: "Juan", last_name: "Dela Cruz", email: "dela_cruz.juan@gmail.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current, is_approve: true, balance: 50000.00) }

  before do
    sign_in user
  end

  describe "GET /dashboard" do
    it "shows dashboard" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard" do
    it "returns to dashboard" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
