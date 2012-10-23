require 'openssl'

SECRET_TOKEN = '01deb307d607be74aeed7253da70c95acde4c0b516abd878c74b48f47520421d28c63eb2e0285d879e8c2b86a9125e8632b52398c1a161f427921f6a91549e8c'

@digest  = OpenSSL::Digest::SHA256.new
@user1 = {
  nickname: 'taka',
  token: '7f5368642bb683cd17e56b87acc1d110b8a6719cf6c8ee230ac7d07a6ee4122b' # '123'
}

def authed?(nickname, pass)
  nickname == @user1[:nickname] and OpenSSL::HMAC.hexdigest(@digest, SECRET_TOKEN, pass) == @user1[:token]
end
