module Handler
  @parser = Yajl::Parser.new
  @encoder = Yajl::Encoder.new

  def handle(evt)
    msg = @parser.parse(evt)
    return case msg.action
    when 'login'
    when 'userlist'
      list = [
        {who: 'taka'},
        {who: 'kimokbin'}
      ]
      chan_list(msg, list)
    else
      chan_object(msg, nil)
    end
  end

  private 
  def chan_object(chan, object)
    @encoder.encode({channel: chan, object: object})
  end

  def chan_list(chan, list)
    @encoder.encode({channel: chan, list: list})
  end

end
