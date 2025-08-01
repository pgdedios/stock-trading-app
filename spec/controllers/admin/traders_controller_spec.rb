require 'rails_helper'

# Tests all admin actions for managing traders (users)
# Covers CRUD operations plus approve/reject functionality with email notifications
RSpec.describe Admin::TradersController, type: :controller do
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

  # Test listing all traders
  describe 'GET index' do
    it 'displays list of all traders' do
      # Create test traders
      trader1 = User.create!(email: 'trader1@test.com', password: 'password123',
                            first_name: 'John', last_name: 'Doe')
      trader2 = User.create!(email: 'trader2@test.com', password: 'password123',
                            first_name: 'Jane', last_name: 'Smith')

      get :index

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:traders)).to include(trader1, trader2)
      expect(assigns(:traders)).not_to include(@admin_user)
    end
  end

  # Test viewing individual trader
  describe 'GET show' do
    it 'displays trader details' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe')

      get :show, params: { id: trader.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns(:trader)).to eq(trader)
    end
  end

  # Test new trader form
  describe 'GET new' do
    it 'displays form to create new trader' do
      get :new

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:trader)).to be_a_new(User)
    end
  end

  # Test trader creation
  describe 'POST create' do
    let(:valid_trader_params) do
      {
        email: 'newtrader@test.com',
        first_name: 'New',
        last_name: 'Trader',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    it 'creates new trader with valid data' do
      expect {
        post :create, params: { user: valid_trader_params }
      }.to change(User, :count).by(1)

      new_trader = User.last
      expect(response).to redirect_to(admin_trader_path(new_trader))
      expect(flash[:notice]).to eq('Trader was successfully created.')
    end

    it 'sends confirmation email when trader is created' do
      expect {
        post :create, params: { user: valid_trader_params }
      }.to change(User, :count).by(1)
       .and change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include('newtrader@test.com')
    end

    it 'handles invalid data gracefully' do
      invalid_params = { email: '', first_name: '', last_name: '' }

      expect {
        post :create, params: { user: invalid_params }
      }.not_to change(User, :count)

      expect(response).to render_template(:new)
    end
  end

  # Test trader editing
  describe 'GET edit' do
    it 'displays form to edit trader' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe')

      get :edit, params: { id: trader.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
      expect(assigns(:trader)).to eq(trader)
    end
  end

  # Test trader updating
  describe 'PATCH update' do
    it 'updates trader with valid data' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe')

      updated_params = { first_name: 'Updated', last_name: 'Name' }

      patch :update, params: { id: trader.id, user: updated_params }

      trader.reload
      expect(trader.first_name).to eq('Updated')
      expect(trader.last_name).to eq('Name')
      expect(response).to redirect_to(admin_trader_path(trader))
      expect(flash[:notice]).to eq('Trader was successfully updated.')
    end
  end

  # Test trader approval functionality
  describe 'PATCH approve' do
    it 'approves pending trader' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe', is_approve: false)

      patch :approve, params: { id: trader.id }

      trader.reload
      expect(trader.is_approve).to eq(true)
      expect(response).to redirect_to(admin_traders_path)
      expect(flash[:notice]).to eq('Trader has been approved.')
    end

    it 'sends approval email notification' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe', is_approve: false)

      expect {
        patch :approve, params: { id: trader.id }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(trader.email)
    end
  end

  # Test trader rejection functionality
  describe 'PATCH reject' do
    it 'rejects pending trader' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe', is_approve: false)

      patch :reject, params: { id: trader.id }

      trader.reload
      expect(trader.is_approve).to eq(false)
      expect(response).to redirect_to(admin_traders_path)
      expect(flash[:notice]).to eq('Trader has been rejected.')
    end

    it 'sends rejection email notification' do
      trader = User.create!(email: 'trader@test.com', password: 'password123',
                           first_name: 'John', last_name: 'Doe', is_approve: false)

      expect {
        patch :reject, params: { id: trader.id }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(trader.email)
    end
  end
end
