class Book < ApplicationRecord
  belongs_to :series

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags

  has_many :ownerships, dependent: :destroy
  has_many :users, through: :ownerships

  has_many :read_histories, dependent: :destroy

  enum status: { unread: 0, reading: 1, finished: 2 }


  def status_label
    I18n.t("enums.book.status.#{status}")
  end

end
