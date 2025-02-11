class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true
  validates :soundcloud_link, format: {
    with: %r{\Ahttps?://(?:www\.)?soundcloud\.com/.*\z}i,
    message: "must be a valid Soundcloud URL (e.g., https://soundcloud.com/username)",
    allow_blank: true
  }

  before_save :ensure_soundcloud_protocol

  has_many :likes, dependent: :destroy
  has_many :drumracks
  has_many :liked_drumracks, through: :likes, source: :drumrack
  has_one_attached :profile_picture
  before_create :check_image_attached

  def like?(drumrack)
    likes.where(drumrack: drumrack).any?
  end

  def check_image_attached
    return if profile_picture.attached?

    profile_picture.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'default-profile.jpg')),
                           filename: 'default-profile.jpg',
                           content_type: 'image/png')
  end

  private

  def ensure_soundcloud_protocol
    return unless soundcloud_link.present? && !soundcloud_link.start_with?('http')

    self.soundcloud_link = "https://#{soundcloud_link}"
  end
end
