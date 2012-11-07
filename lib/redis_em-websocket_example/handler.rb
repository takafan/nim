require 'yajl'
require 'openssl'
require 'securerandom'
require File.expand_path('../models/user.rb', __FILE__)

module Handler
  # 处理事件
  def handle(ws, evt)
    puts "evt: #{evt}"
    msg = Yajl::Parser.parse(evt)
    begin
      case msg['action']
      when 'login'  
        handle_login(ws, msg)
      when 'logout'  
        handle_logout(ws)
      when 'signup' 
        handle_signup(ws, msg)
      end
    rescue RuntimeError => e
      ws.send notice(e.message)
    end
  end

  def init_ws(ws)
    # 加入sockets
    @sockets[ws] = nil

    # 响应
    res = {
      action: 'initialize', 
      message: @configurations['app']['greeting'],
      title: @configurations['ws']['title']
    }
    ws.send encode(res)
    puts "send: #{res}"
  end

  # 弹框消息
  def notice(msg)
    encode({action: 'notice', message: msg})
  end

  # 私聊消息
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

  # 绑用户
  def bind_user(ws, user=nil)
    if user
      # 绑定用户
      action = 'userlist.add'
      username = user.username
      @sockets[ws] = user.username
    else
      # 释放用户
      action = 'userlist.del'
      username = @sockets[ws]
      @sockets[ws] = nil
    end
    puts "o#{@sockets.values.select{|u| u}.size} s#{@sockets.size}"

    bc = {
      action: action,
      username: username 
    }
    send2onlines(bc)
    puts "send2onlines: #{res}"
  end

  # 登录
  def handle_login(ws, msg)
    user = User.find_by_username(msg['username'])
    # 验证
    raise 'Incorrect username or password. ' if user.nil? or user.cpass != OpenSSL::HMAC.hexdigest('sha256', user.salt, msg['pass'])

    # 绑用户
    bind_user(ws, user)

    # 响应
    res = { 
      action: 'login.ok',
      username: user.username,
      userlist: @sockets.values.select{|u| u}
    }
    ws.send encode(res)
    puts "send: #{res}"
  end

  # 退出
  def handle_logout(ws)
    # 解绑用户
    bind_user(ws, nil)

    # 响应
    res = { 
      action: 'logout.ok'
    }
    ws.send encode(res)
    puts "send: #{res}"
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

    # 绑用户
    bind_user(ws, user)

    # 响应
    res = {
      action: 'signup.ok',
      username: user.username
    }
    ws.send encode(res)
    puts "send: #{res}"
  end

  

end
