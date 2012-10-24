require 'yajl'

module Handler

  def handle(msg)
    return case msg
    when 'userlist'
      list = [
        {who: 'taka'},
        {who: 'kimokbin'}
      ]
      chan_list(msg, list)
    when 'chat1.latest10'
      list = [
        {who: 'taka', say: 'nice to meet u'},
        {who: 'kimokbin', say: 'nice to meet u too'}
      ]
      chan_list(msg, list)
    else
      chan_object(msg, nil)
    end
  end

  private 
  def chan_object(chan, object)
    Yajl::Encoder.encode({channel: chan, object: object})
  end

  def chan_list(chan, list)
    Yajl::Encoder.encode({channel: chan, list: list})
  end

end