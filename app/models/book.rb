class Book < ApplicationRecord
  belongs_to :series, optional: true

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  has_many :ownerships, dependent: :destroy
  has_many :users, through: :ownerships
  has_many :read_histories, dependent: :destroy
  has_one_attached :cover_image

  validates :title, presence: true
  validates :author, presence: true
  validates :title, uniqueness: { scope: [:author, :series_id] }
end
