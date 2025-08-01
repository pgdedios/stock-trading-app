require 'rails_helper'

RSpec.describe "Portfolios", type: :request do
  let!(:user) { User.create(first_name: "Juan", last_name: "Dela Cruz", email: "dela_cruz.juan@gmail.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current, is_approve: true, balance: 50000.00) }

  before do
    # Simulate initial state: user owns 2 shares of NFLX
    @initial_transaction = Transaction.create!(
      company_name: "NETFLIX INC",
      stock_symbol: "NFLX",
      transaction_type: "buy",
      quantity: 2,
      price_at_time: 1241.96,
      total_amount: 2 * 1241.96,
      user: user
    )

    sign_in user
  end

  describe "GET /portfolios" do
    it "returns the portfolio index page" do
      get portfolios_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /portfolio/:id" do
    it "shows the details of a portfolio" do
      portfolio = user.portfolios.find_by(stock_symbol: "NFLX")
      expect(portfolio).not_to be_nil

      get portfolio_path(portfolio.id)
      expect(response).to have_http_status(:success)
    end
  end
end
