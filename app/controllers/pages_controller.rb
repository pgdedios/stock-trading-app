class PagesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def unconfirmed
  end

  def pending_approval
  end
end
