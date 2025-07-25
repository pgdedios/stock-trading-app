require 'rails_helper'

RSpec.describe "Portfolios", type: :request do
  let!(:user) { User.create(first_name: "Juan", last_name: "Dela Cruz", email: "dela_cruz.juan@gmail.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current, is_approve: true) }

  before do
    sign_in user
  end

  describe "GET /portfolios" do
    let!(:portfolio) { Portfolio.create(company_name: "NETFLIX INC", stock_symbol: "NFLX", quantity: 2, current_price: 1241.96, total_amount: 2 * 1241.96, user: user) }

    it "Allows access to the portfolio index" do
      get portfolios_path
      expect(response).to have_http_status(:success)
    end

    it "Shows the details of clicked portfolio" do
      get portfolio_path(portfolio.id)
      expect(response).to have_http_status(:success)
    end
  end
end
