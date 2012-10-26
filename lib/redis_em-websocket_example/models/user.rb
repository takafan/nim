class User < ActiveRecord::Base
  attr_accessible :login, :salt, :cpass, :email

  # validates :login, presence: true, uniqueness: true, format: { with: /\A[^_][A-Za-z0-9_]?+\Z/,
  #   message: "Login may only contain alphanumeric characters or dashes and cannot begin with a dash" }
end
