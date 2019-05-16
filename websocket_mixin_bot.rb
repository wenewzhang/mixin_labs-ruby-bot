require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'zlib'
require 'mixin_bot'
require 'yaml'
require './utils'

yaml_hash = YAML.load_file('./config.yml')

MixinBot.client_id  = yaml_hash["MIXIN_CLIENT_ID"]
MixinBot.session_id = yaml_hash["MIXIN_SESSION_ID"]
MixinBot.client_secret = yaml_hash["MIXIN_CLIENT_SECRET"]
MixinBot.pin_token   = yaml_hash["MIXIN_PIN_TOKEN"]
MixinBot.private_key = yaml_hash["MIXIN_PRIVATE_KEY"]

# access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJ1aWQiOiIwNTA4YTExNi0xMjM5LTRlMjgtYjE1MC04NWE4ZTNlNmI0MDAiLCJzaWQiOiIxOTE0MzM3ZS1kYTEwLTRiMzAtODM5MC1hNmNjNTIwMWQ3MjYiLCJpYXQiOjE1MzMxMDc4MjEsImV4cCI6MTUzMzE5NDIyMSwianRpIjoiNDY1YjUxZjAtMmExOC00YTFmLWI4ODctMWQ2YzMyMDE5NjUyIiwic2lnIjoiZjgzN2ViZWI0YzI5ODFhZDljNjRiNzBkMGIwZDE4NzI0Yzc2YzYwNzgxYjllNGJmN2E1ODI1MTBkZjdhZGEzOSJ9.QOCum6h7Vkp6nrUsp7zLjshETwdJYwYL5wS3lU9x6HlonWRy2t3UT1MPQ_ekG-K7aaQ-D1OKjqcMpHY4yjj8rFXxfIQ6Lus1rdYY2C1WLo8vn209FkfHbrEXptDQIhiIxN1WaYXFjWvrDxISRdd4Fi3X7gWUXZ-nKLcObTgdvRo"

access_token = MixinBot.api.access_token("GET","/","")
puts access_token

authorization = format('Bearer %s', access_token)



EM.run {
  ws = Faye::WebSocket::Client.new('wss://blaze.mixin.one/', ["Mixin-Blaze-1"],
    :headers => { 'Authorization' => authorization }
  )

  ws.on :open do |event|
    p [:open]
    ws.send(Utils.ListPendingMsg)
  end

  ws.on :message do |event|
    p [:message]
    data = event.data
    io = StringIO.new(data.pack('c*'), 'rb')
    gzip = Zlib::GzipReader.new io
    msg = gzip.read
    gzip.close
    jsmsg =  JSON.parse msg
    p jsmsg
    p jsmsg["data"]
    if jsmsg["action"] == "CREATE_MESSAGE" && jsmsg["data"] != nil
      ws.send(Utils.GenerateReceipt(jsmsg["data"]["message_id"]))
      if jsmsg["data"]["category"] == "PLAIN_TEXT"
        p Base64.decode64(jsmsg["data"]["data"])
        replyMsg = Utils.SendPlainText(jsmsg["data"]["conversation_id"],Base64.decode64(jsmsg["data"]["data"]))
        ws.send(replyMsg)
      end
      if jsmsg["data"]["category"] == "SYSTEM_ACCOUNT_SNAPSHOT"
        jsdata =  JSON.parse (Base64.decode64(jsmsg["data"]["data"]))
        p jsdata
      end
    end
  end

  ws.on :error do |event|
    p [:error]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
