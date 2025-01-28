class Sample < ApplicationRecord
  has_many :drumrack_samples, dependent: :destroy
  has_many :pad_drumrack_samples, through: :drumrack_samples
  has_many :pads, through: :pad_drumrack_samples
  has_many :drumracks, through: :drumrack_samples

  has_one_attached :sound
  enum category: { bass: 0, kick: 10, snare: 20, hihat: 30, oneshot: 40 }

  validates :category, presence: true
  before_destroy :purge_sound

  private

  def purge_sound
    sound.purge
  end
end
