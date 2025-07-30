class Admin::DashboardController < Admin::ApplicationController
  def index
    @stats = dashboard_stats
  end

  def not_found
    render template: "admin/errors/not_found", status: 404
  end

  private

  def dashboard_stats
    {
      total_traders: User.traders.count,
      pending_traders: User.traders.pending.count,
      approved_traders: User.traders.approved.count,
      total_transactions: Transaction.for_traders.count,
      recent_transactions: Transaction.for_traders.recent.limit(5).includes(:user)
    }
  end
end
