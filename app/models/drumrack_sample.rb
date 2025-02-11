class DrumrackSample < ApplicationRecord
  belongs_to :sample
  belongs_to :drumrack
  has_many :pad_drumrack_samples, dependent: :destroy
end
