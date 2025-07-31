require 'rails_helper'

# Tests the admin dashboard that displays system statistics
# This controller shows overview data like trader counts, transactions, etc.
RSpec.describe Admin::DashboardController, type: :controller do
  # Set up admin user for all tests
  before do
    @admin_user = User.create!(
      email: 'admin@test.com',
      password: 'password123',
      first_name: 'Admin',
      last_name: 'User',
      is_admin: true,
      confirmed_at: Time.current
    )
    sign_in @admin_user
  end

  describe 'GET index' do
    it 'loads the dashboard page successfully' do
      get :index

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    it 'displays system statistics with test data' do
      # Create test traders with different approval statuses
      trader1 = User.create!(email: 'trader1@test.com', password: 'password123',
                            first_name: 'Trader', last_name: 'One', is_approve: true)
      trader2 = User.create!(email: 'trader2@test.com', password: 'password123',
                            first_name: 'Trader', last_name: 'Two', is_approve: false)
      trader3 = User.create!(email: 'trader3@test.com', password: 'password123',
                            first_name: 'Trader', last_name: 'Three', is_approve: false)

      # Create portfolio and transactions for testing
      portfolio = Portfolio.create!(
        user: trader1,
        stock_symbol: 'AAPL',
        company_name: 'Apple Inc.',
        current_price: 150.00,
        quantity: 10,
        total_amount: 1500.00
      )

      Transaction.create!(user: trader1, company_name: 'Apple Inc.', stock_symbol: 'AAPL',
                         transaction_type: 'buy', quantity: 10, price_at_time: 150.00, total_amount: 1500.00)
      Transaction.create!(user: trader1, company_name: 'Apple Inc.', stock_symbol: 'AAPL',
                         transaction_type: 'buy', quantity: 5, price_at_time: 155.00, total_amount: 775.00)

      get :index

      # Verify dashboard loads successfully with test data
      expect(response).to have_http_status(:success)
    end

    it 'handles empty data gracefully' do
      # Ensure no trader or transaction data exists
      User.where(is_admin: false).destroy_all
      Transaction.destroy_all

      get :index

      # Dashboard should still load without errors
      expect(response).to have_http_status(:success)
    end
  end
end
