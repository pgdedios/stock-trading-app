class PagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @transactions = current_user.transactions.order(created_at: :desc).limit(3)
    @portfolios = current_user.portfolios.order(updated_at: :desc).limit(3)
  end

  def unconfirmed
  end

  def pending_approval
  end
end
