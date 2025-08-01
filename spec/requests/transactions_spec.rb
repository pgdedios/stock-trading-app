require 'rails_helper'

RSpec.describe "Transactions", type: :request do
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

  describe "GET /transactions" do
    it "returns the transaction index page" do
      get transactions_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /transactions/:id" do
    it "shows the details of a transaction" do
      get transaction_path(@initial_transaction.id)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /transactions/new" do
    it "opens the buy form" do
      get new_transaction_path(type: "buy")
      expect(response).to have_http_status(:success)
    end

    it "opens the sell form" do
      get new_transaction_path(type: "sell")
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /transactions" do
    it "buys a stock and updates portfolio and balance" do
      expect do
        post transactions_path, params: {
          transaction: {
            company_name: "NETFLIX INC",
            stock_symbol: "NFLX",
            transaction_type: "buy",
            quantity: 1,
            price_at_time: 1241.96,
            total_amount: 1241.96
          }
        }
      end.to change(Transaction, :count).by(1)

      expect(response).to have_http_status(:redirect)

      user.reload
      portfolio = user.portfolios.find_by(stock_symbol: "NFLX")

      expect(portfolio).not_to be_nil
      expect(portfolio.quantity).to eq(3)
      expect(portfolio.total_amount).to be_within(0.01).of(3 * 1241.96) # 3725.88
      expect(user.balance).to be_within(0.01).of(50000 - 3 * 1241.96)
    end

    it "successfully sells a stock" do
      expect do
        post transactions_path, params: {
          transaction: {
            company_name: "NETFLIX INC",
            stock_symbol: "NFLX",
            transaction_type: "sell",
            quantity: 1,
            price_at_time: 1241.96,
            total_amount: 1241.96
          }
        }
      end.to change(Transaction, :count).by(1)

      expect(response).to have_http_status(:redirect)

      user.reload
      portfolio = user.portfolios.find_by(stock_symbol: "NFLX")

      # Final balance: 50000 - 2*1241.96 + 1*1241.96 = 50000 - 1241.96 = 48758.04
      expect(user.balance).to be_within(0.01).of(50000 - 1241.96)

      expect(portfolio).not_to be_nil
      expect(portfolio.quantity).to eq(1)
      expect(portfolio.total_amount).to be_within(0.01).of(1241.96)
    end

    it "fails to buy due to insufficient balance" do
      expect do
        post transactions_path, params: {
          transaction: {
            company_name: "TESLA INC",
            stock_symbol: "TSLA",
            transaction_type: "buy",
            quantity: 100,
            price_at_time: 1241.96,
            total_amount: 100 * 1241.96
          }
        }
      end.not_to change(Transaction, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Transaction failed.")

      user.reload
      expect(user.balance).to eq(47516.08)
      expect(user.portfolios.find_by(stock_symbol: "TSLA")).to be_nil
    end

    it "fails to sell due to insufficient stocks" do
      # User owns 2 shares from setup
      expect(user.portfolios.find_by(stock_symbol: "NFLX").quantity).to eq(2)

      expect do
        post transactions_path, params: {
          transaction: {
            company_name: "NETFLIX INC",
            stock_symbol: "NFLX",
            transaction_type: "sell",
            quantity: 5, # More than owned
            price_at_time: 1241.96,
            total_amount: 5 * 1241.96
          }
        }
      end.not_to change(Transaction, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Transaction failed.")

      user.reload
      portfolio = user.portfolios.find_by(stock_symbol: "NFLX")
      expect(portfolio.quantity).to eq(2)
      expect(user.balance).to be_within(0.01).of(50000 - 2 * 1241.96)
    end
  end
end
