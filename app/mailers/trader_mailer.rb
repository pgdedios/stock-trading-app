class TraderMailer < ApplicationMailer
  default from: "noreply@stocktradingapp.com"

  def approval_notification(trader)
    @trader = trader
    @login_url = new_user_session_url

    mail(
      to: @trader.email,
      subject: "Your trading account has been approved!"
    )
  end

  def rejection_notification(trader)
    @trader = trader

    mail(
      to: @trader.email,
      subject: "Trading account application update"
    )
  end
end
