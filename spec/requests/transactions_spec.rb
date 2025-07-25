require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  let!(:user) { User.create(first_name: "Juan", last_name: "Dela Cruz", email: "dela_cruz.juan@gmail.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current, is_approve: true) }

  before do
    sign_in user
  end

  describe "GET /transactions" do
    let!(:transaction) { Transaction.create(company_name: "NETFLIX INC", stock_symbol: "NFLX", transaction_type: "buy", quantity: 2, price_at_time: 1241.96, total_amount: 2 * 1241.96, user: user) }

    it "Allows access to the transaction index" do
      get transactions_path
      expect(response).to have_http_status(:success)
    end

    it "Shows the details of clicked transaction" do
      get transaction_path(transaction.id)
      expect(response).to have_http_status(:success)
    end
  end
end
