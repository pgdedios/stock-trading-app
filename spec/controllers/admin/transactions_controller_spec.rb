require 'rails_helper'

# Tests the admin view of all transactions (read-only interface)
# Admins can view and monitor all trading activity but cannot modify transactions
RSpec.describe Admin::TransactionsController, type: :controller do
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

  # Test listing all transactions
  describe 'GET index' do
    it 'displays list of all transactions' do
      # Create test trader with sufficient balance and approval
      trader = User.create!(
        email: 'trader@test.com',
        password: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        balance: 50000.00,
        is_approve: true,
        confirmed_at: Time.current
      )

      # Create test transactions (using buy orders to avoid validation issues)
      transaction1 = Transaction.create!(
        user: trader,
        company_name: 'Apple Inc.',
        stock_symbol: 'AAPL',
        transaction_type: 'buy',
        quantity: 10,
        price_at_time: 150.00,
        total_amount: 1500.00
      )

      transaction2 = Transaction.create!(
        user: trader,
        company_name: 'Microsoft Corp.',
        stock_symbol: 'MSFT',
        transaction_type: 'buy',
        quantity: 5,
        price_at_time: 200.00,
        total_amount: 1000.00
      )

      get :index

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:transactions)).to include(transaction1, transaction2)
    end

    it 'handles empty transaction list' do
      Transaction.destroy_all

      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:transactions)).to be_empty
    end

    it 'orders transactions by newest first' do
      trader = User.create!(
        email: 'trader@test.com',
        password: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        balance: 50000.00,
        is_approve: true,
        confirmed_at: Time.current
      )

      # Create transactions with different timestamps
      old_transaction = Transaction.create!(
        user: trader,
        company_name: 'Apple Inc.',
        stock_symbol: 'AAPL',
        transaction_type: 'buy',
        quantity: 10,
        price_at_time: 150.00,
        total_amount: 1500.00,
        created_at: 2.days.ago
      )

      new_transaction = Transaction.create!(
        user: trader,
        company_name: 'Microsoft Corp.',
        stock_symbol: 'MSFT',
        transaction_type: 'buy',
        quantity: 5,
        price_at_time: 200.00,
        total_amount: 1000.00,
        created_at: 1.day.ago
      )

      get :index

      transactions = assigns(:transactions)
      expect(transactions.first).to eq(new_transaction)
      expect(transactions.last).to eq(old_transaction)
    end
  end

  # Test viewing individual transaction
  describe 'GET show' do
    it 'displays transaction details' do
      trader = User.create!(
        email: 'trader@test.com',
        password: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        balance: 50000.00,
        is_approve: true,
        confirmed_at: Time.current
      )

      transaction = Transaction.create!(
        user: trader,
        company_name: 'Apple Inc.',
        stock_symbol: 'AAPL',
        transaction_type: 'buy',
        quantity: 10,
        price_at_time: 150.00,
        total_amount: 1500.00
      )

      get :show, params: { id: transaction.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns(:transaction)).to eq(transaction)
    end

    it 'includes associated user and stock information' do
      trader = User.create!(
        email: 'trader@test.com',
        password: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        balance: 50000.00,
        is_approve: true,
        confirmed_at: Time.current
      )

      transaction = Transaction.create!(
        user: trader,
        company_name: 'Apple Inc.',
        stock_symbol: 'AAPL',
        transaction_type: 'buy',
        quantity: 10,
        price_at_time: 150.00,
        total_amount: 1500.00
      )

      get :show, params: { id: transaction.id }

      loaded_transaction = assigns(:transaction)
      expect(loaded_transaction.user).to eq(trader)
      expect(loaded_transaction.stock_symbol).to eq('AAPL')
      expect(loaded_transaction.company_name).to eq('Apple Inc.')
    end
  end
end
