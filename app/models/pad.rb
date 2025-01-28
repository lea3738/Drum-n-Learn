class Pad < ApplicationRecord
  belongs_to :drumrack
  has_many :pad_drumrack_samples, dependent: :destroy
  has_many :drumrack_samples, through: :pad_drumrack_samples
  has_many :samples, through: :drumrack_samples

  validate :make_sure_pad_has_5_drumrack_samples
  validates :step, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 16 }

  private

  def make_sure_pad_has_5_drumrack_samples
    if drumrack_samples.size > 5
      errors.add(:base, "must have 5 drumrack samples")
    end
  end

end
