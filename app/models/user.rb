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
  has_many :group_messages, dependent: :nullify
  # has_many :group_invitations, dependent: :destroy

  validates_uniqueness_of :email, case_sensitive: false
end
