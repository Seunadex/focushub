class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  validates :name, presence: true
  validates :slug, uniqueness: true, presence: true
  validates :privacy, presence: true

  enum :privacy, { public: 0, private: 1, secret: 2 }
end
