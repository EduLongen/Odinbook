class Post < ApplicationRecord
  validates_presence_of :body
  belongs_to :user
  has_rich_text :body
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
end
