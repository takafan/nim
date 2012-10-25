require 'openssl'
require File.expand_path('../config/secret_token.rb', __FILE__)

@digest  = OpenSSL::Digest::SHA256.new
@user1 = {
  nickname: 'taka',
  token: '7f5368642bb683cd17e56b87acc1d110b8a6719cf6c8ee230ac7d07a6ee4122b' # '123'
}

def authed?(nickname, pass)
  nickname == @user1[:nickname] and OpenSSL::HMAC.hexdigest(@digest, SECRET_TOKEN, pass) == @user1[:token]
end