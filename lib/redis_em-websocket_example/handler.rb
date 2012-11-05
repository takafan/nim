require 'yajl'
require 'openssl'
require 'securerandom'
require File.expand_path('../models/user.rb', __FILE__)

module Handler
  
  def handle(wskey, evt)
    msg = Yajl::Parser.parse(evt)
    begin
      res = case msg['action']
      when 'login'  # 登录
        handle_login(wskey, msg)
      when 'signup' # 注册
        handle_signup(wskey, msg)
      end
    rescue RuntimeError => e
      return notice(e.message)
    end
    
    res.nil? ? nil : encode({action: msg['action'] + '.ok'}.merge(res))
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

  def notice(msg)
    encode({action: 'notice', message: msg})
  end

  def syspop(msg)
    encode({action: 'syspop', message: msg})
  end

  private
  def encode(hash)
    Yajl::Encoder.encode(hash)
  end

  def handle_login(wskey, msg)
    user = User.find_by_username(msg['username'])
    if user.nil? or user.cpass != OpenSSL::HMAC.hexdigest('sha256', user.salt, msg['pass'])
      raise 'Incorrect username or password. '
    end
    
    @onlines[wskey] = user.username
    puts "o#{@onlines.size}"
    
    { username: user.username }
  end

  def handle_signup(wskey, msg)
    errs = []
    if msg['username'].nil? or msg['username'].strip.empty? or msg['username'] !~ /\A[^_][A-Za-z0-9_]?+\z/
      errs << 'Username may only contain alphanumeric characters or dashes and cannot begin with a dash' 
    elsif User.find_by_username(msg['username'])
      errs << 'Username is already taken.'
    end
    if msg['email'] and !msg['email'].empty? 
      if msg['email'] !~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ or User.find_by_email(msg['email'])
        errs << 'Email is invalid or already taken'
      end
    end
    raise errs.join('\n') if errs.size > 0

    key = SecureRandom.hex
    cpass = OpenSSL::HMAC.hexdigest('sha256', key, msg['pass'])
    user = User.create!(
      username: msg['username'],
      salt: key,
      cpass: cpass,
      email: msg['email']
    )
    @onlines[wskey] = user.username
    puts "o#{@onlines.size}"
    
    { username: user.username }
  end

end
