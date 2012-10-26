require 'yajl'
require 'openssl'
require 'securerandom'
require File.expand_path('../models/user.rb', __FILE__)

module Handler
  
  def handle(wskey, evt)
    msg = Yajl::Parser.parse(evt)
    res = case msg['action']
    when 'login'
      {message: 'login...'}
    when 'signup'
      
      key = SecureRandom.hex
      cpass = OpenSSL::HMAC.hexdigest('sha256', key, msg['pass'])
      user = User.create!(
        login: msg['login'],
        salt: key,
        cpass: cpass,
        email: msg['email']
      )
      if user
        puts user.inspect
        @onlines[wskey] = user.login
        puts "o#{@onlines.size}"
        {login: user.login}
      else
        {login: nil}
      end
    end

    res.nil? ? nil : encode({action: msg['action']}.merge(res))
  end

  def validate_signup(msg)
    errs = []
    if msg['login'].nil? or msg['login'].strip.empty? or !msg['login'].match(/\A[^_][A-Za-z0-9_]?+\Z/)
      errs << 'Login may only contain alphanumeric characters or dashes and cannot begin with a dash' 
    elsif User.find_by_login(msg['login'])
      errs << 'Login '
    end
    
  end

  def load_hall
    encode({
      action: 'load_hall', 
      userlist: [
        {name: 'taka'},
        {name: 'kimokbin'}
      ]
    })
  end

  def greeting
    syspop(@configurations['app']['greeting'])
  end

  def syspop(msg)
    encode({action: 'syspop', message: msg})
  end

  private
  def encode(hash)
    Yajl::Encoder.encode(hash)
  end

end
