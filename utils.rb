module Utils
  def self.GenerateReceipt(msgid)
    params = {
      "message_id": msgid,
      "status": "READ"
    }
    msg = {
      "id":SecureRandom.uuid,
      "action":"ACKNOWLEDGE_MESSAGE_RECEIPT",
      "params":params
    }
    io = StringIO.new 'wb'
    gzip = Zlib::GzipWriter.new io
    gzip.write msg.to_json
    gzip.close
    data = io.string.unpack('c*')
    return data
  end

  def self.ListPendingMsg
    msg = {
      "id": SecureRandom.uuid,
      "action": "LIST_PENDING_MESSAGES"
    }
    io = StringIO.new 'wb'
    gzip = Zlib::GzipWriter.new io
    gzip.write msg.to_json
    gzip.close
    data = io.string.unpack('c*')
    return data
  end

  def self.SendPlainText(conid,content)
    params = {
      "conversation_id":conid,
      'category':'PLAIN_TEXT',
      'status':'SENT',
      'message_id':SecureRandom.uuid,
      'data':Base64.encode64(content)
      }
    msg = {
      'id':SecureRandom.uuid,
      'action':'CREATE_MESSAGE',
      'params':params
      }
      io = StringIO.new 'wb'
      gzip = Zlib::GzipWriter.new io
      gzip.write msg.to_json
      gzip.close
      data = io.string.unpack('c*')
      return data
  end

end
