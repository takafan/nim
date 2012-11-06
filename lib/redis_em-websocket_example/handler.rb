require 'yajl'
require 'openssl'
require 'securerandom'
require File.expand_path('../models/user.rb', __FILE__)

module Handler
  
  def handle(ws, evt)
    msg = Yajl::Parser.parse(evt)
    begin
      case msg['action']
      when 'login'  
        handle_login(ws, msg)
      when 'signup' 
        handle_signup(ws, msg)
      end
    rescue RuntimeError => e
      ws.send notice(e.message)
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

  # 广播在线用户
  def send2onlines(hash)
    @sockets.select{|s, u| u}.each{|s, u| sock.send encode(hash)}
  end

  # 绑定用户到socket对象
  def bind_socket(ws, user=nil)
    @sockets[ws] = user.username
    puts "o#{@sockets.values.select{|u| u}.size} s#{@sockets.size}"

    bc = {
      action: 'userlist.add',
      username: user.username 
    }
    send2onlines(bc)
    puts "send2onlines: #{res}"
  end

  # 登录
  def handle_login(ws, msg)
    user = User.find_by_username(msg['username'])
    # 验证
    raise 'Incorrect username or password. ' if user.nil? or user.cpass != OpenSSL::HMAC.hexdigest('sha256', user.salt, msg['pass'])

    # 响应
    res = { 
      action: 'login.ok',
      username: user.username
    }
    ws.send encode(res)
    puts "send: #{res}"

    # ws.request['sec-websocket-key']
    bind_socket(ws, user)
  end

  # 退出
  def handle_logout(ws)
    @sockets[ws] = nil

    # 响应
    res = { 
      action: 'logout.ok'
    }
    ws.send encode(res)
    puts "send: #{res}"

    bind_socket(ws, user)
  end

  # 注册
  def handle_signup(ws, msg)
    # 验证
    raise 'Please enter your Username' if msg['username'].nil? or msg['username'].strip.empty? 
    username = CGI::escapeHTML(msg['username'].strip)
    raise 'This username is already in use, please pick another one' if User.find_by_username(username)

    raise 'Please enter your Password' if msg['pass'].nil? or msg['pass'].empty? 
    pass = CGI::escapeHTML(msg['pass'])
    raise 'The Password is too short' if pass.size <= 1

    email = CGI::escapeHTML(msg['email'].strip) if msg['email'] and !msg['email'].strip.empty?

    # 创建用户
    key = SecureRandom.hex
    cpass = OpenSSL::HMAC.hexdigest('sha256', key, pass)
    user = User.create!(
      username: username,
      salt: key,
      cpass: cpass,
      email: email
    )

    # 响应
    res = {
      action: 'signup.ok',
      username: user.username
    }
    ws.send encode(res)
    puts "send: #{res}"

    bind_socket(ws, user)
  end

  

end
