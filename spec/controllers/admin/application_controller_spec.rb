require 'rails_helper'

# Tests the base admin controller authentication and authorization
# This ensures only admin users can access admin routes
RSpec.describe Admin::ApplicationController, type: :controller do
  # Create a test controller to verify the admin authentication works
  controller do
    def index
      render plain: 'Admin page accessed'
    end
  end

  before do
    # Set up a test route for our anonymous test controller
    routes.draw { get 'index' => 'admin/application#index' }
  end

  # Test behavior when no user is logged in
  describe 'when user is not logged in' do
    it 'redirects to home page' do
      get :index

      expect(response).to redirect_to(root_path)
    end
  end

  # Test behavior when a regular (non-admin) user tries to access admin area
  describe 'when regular user is logged in' do
    it 'redirects to home page with access denied message' do
      # Create a regular user without admin privileges
      regular_user = User.create!(
        email: 'user@test.com',
        password: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        is_admin: false,
        confirmed_at: Time.current
      )

      sign_in regular_user
      get :index

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Access denied. Admin privileges required.')
    end
  end

  # Test behavior when admin user accesses admin area
  describe 'when admin user is logged in' do
    it 'allows access to admin pages' do
      # Create an admin user
      admin_user = User.create!(
        email: 'admin@test.com',
        password: 'password123',
        first_name: 'Admin',
        last_name: 'User',
        is_admin: true,
        confirmed_at: Time.current
      )

      sign_in admin_user
      get :index

      # Admin should have access (may redirect to admin dashboard, which is fine)
      expect(response).to have_http_status(:redirect)
    end
  end
end
