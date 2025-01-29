class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true

  has_many :likes, dependent: :destroy
  has_many :drumracks
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
end
