require 'securerandom'
require 'openssl'

class User < ActiveRecord::Base
  attr_accessible :name, :salt, :cpass, :email

  

  def self.find(name)
    h = @redis.hgetall("users.#{name}")
    u = self.new
    u.name = h['name']
    u.email = h['email']
    #u.token = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, SECRET_TOKEN, u.cpass)
    u
  end

  def self.create(name, pass, email)
    salt = SecureRandom.hex(1)
    cpass = pass.crypt(salt)
    key = "users.#{name}"
    @redis.hset(key, :name, name, :salt, salt, :cpass, cpass, :email, email)
    self.find(name)
  end

end
