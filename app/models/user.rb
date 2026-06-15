class User < ApplicationRecord
  has_secure_password
  has_many :ownerships, dependent: :destroy
  has_many :books, through: :ownerships

  has_many :read_histories, dependent: :destroy
  #バリデーション
  validates :email, presence: true, uniqueness: true
  validates :user_name, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, presence: true, on: :create

  # ゲストユーザー判定
  def guest?
    email == "guest@example.com"
  end
end
