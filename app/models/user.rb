class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  attribute :balance, default: 50000
  has_many :transactions
  has_many :portfolios

  # Scopes
  scope :traders, -> { where(is_admin: false) }
  scope :admins, -> { where(is_admin: true) }
  scope :approved, -> { where(is_approve: true) }
  scope :pending, -> { where(is_approve: false) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Ransack configuration - Define which attributes can be searched
  def self.ransackable_attributes(auth_object = nil)
    # Only allow safe attributes to be searched (NO sensitive data)
    [ "first_name", "last_name", "email", "balance", "is_approve", "confirmed_at", "created_at", "updated_at", "id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    # Allow searching through associations
    [ "transactions", "portfolios" ]
  end

  def portfolio_value
    portfolios.sum(:total_amount)
  end

  def total_trades
    transactions.count
  end

  def buy_transactions_count
    transactions.where(transaction_type: "buy").count
  end

  def sell_transactions_count
    transactions.where(transaction_type: "sell").count
  end

  def total_invested
    transactions.where(transaction_type: "buy").sum(:total_amount)
  end

  def total_earnings
    transactions.where(transaction_type: "sell").sum(:total_amount)
  end

  def net_profit_loss
    total_earnings - total_invested
  end

  def can_trade?
    is_approve? && confirmed_at.present?
  end

  def status
    return "Ready to Trade" if can_trade?
    return "Awaiting Approval" if confirmed_at.present?
    "Email Not Confirmed"
  end

  def full_name_with_email
    "#{first_name} #{last_name} (#{email})"
  end

  def send_approval_notification
    TraderMailer.approval_notification(self).deliver_now
  end

  def send_rejection_notification
    TraderMailer.rejection_notification(self).deliver_now
  end

  def active_for_authentication?
    super && is_approve?
  end

  def inactive_message
    if !is_approve? && !confirmed?
      :unconfirmed
    elsif !confirmed?
      :unconfirmed
    elsif !is_approve?
      :not_approved
    else
      super
    end
  end
end
