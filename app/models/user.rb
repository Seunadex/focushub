class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :tasks, dependent: :destroy
  has_many :habits, dependent: :destroy

  validates_uniqueness_of :email, case_sensitive: false

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
