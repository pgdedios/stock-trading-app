class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

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
