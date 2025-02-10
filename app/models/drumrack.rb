class Drumrack < ApplicationRecord
  has_many :pads, dependent: :destroy
  has_many :drumrack_samples, dependent: :destroy
  has_many :pad_drumrack_samples, through: :pads
  has_many :likes, dependent: :destroy
  has_many :samples, through: :drumrack_samples
  # we limit the number of associated drumrack_samples to 5
  validate :limit_number_of_associated_samples_to_five
  validate :limit_associated_samples_to_one_per_category
  validates :name, presence: true
  validates :genre, presence: true
  validates :bpm, presence: true
  belongs_to :user, optional: true
  after_create :create_pads

  scope :templates, -> { where(is_template: true) }
  scope :user_drumracks, -> { where(is_template: false) }
  scope :ordered_by_likes, -> { left_joins(:likes).group('drumracks.id').order('COUNT(likes.id) DESC')}


  private

  def limit_number_of_associated_samples_to_five
    return if samples.size <= 5

    errors.add(:base, "can't be more than 5")
  end

  def limit_associated_samples_to_one_per_category
    categories = samples.map(&:category)
    return if categories.size == categories.uniq.size

    errors.add(:base, "can't have more than one sample per category")
  end

  def create_pads
    16.times do |i|
      pad = Pad.new(step: i + 1)
      pad.drumrack = self
      pad.save
    end
  end
end
