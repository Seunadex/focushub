class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :tasks, dependent: :destroy
  has_many :habits, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  validates_uniqueness_of :email, case_sensitive: false

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def abbreviated_name
    if first_name.present? && last_name.present?
      "#{first_name.first.upcase}#{last_name.first.upcase}"
    elsif first_name.present?
      first_name.first.upcase
    elsif last_name.present?
      last_name.first.upcase
    else
      "U"
    end
  end
end
