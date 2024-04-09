class User < ApplicationRecord
  has_secure_password
  has_and_belongs_to_many :roles
  has_many :projects, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  validates_uniqueness_of :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :userid, :fullname, presence: true, length: {minimum: 5}
  validates :password, presence: true, length: {minimum: 5}, on: :create
  # attr_accessor :project_id
  # attr_accessor :role_id
  
end
