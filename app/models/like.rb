class Like < ApplicationRecord
  belongs_to :user
  belongs_to :drumrack

  validates :user, uniqueness: { scope: :drumrack }
end
