class Book < ApplicationRecord
  belongs_to :series

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  has_many :ownerships, dependent: :destroy
  has_many :users, through: :ownerships
  has_many :read_histories, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :author, presence: true

end
