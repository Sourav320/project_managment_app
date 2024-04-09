class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user
  validates :title, presence: true, length: {minimum: 1}
  validates :description, presence: true
  has_one_attached :important_file

end
