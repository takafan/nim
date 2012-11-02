class User < ActiveRecord::Base
  attr_accessible :username, :salt, :cpass, :email

end
