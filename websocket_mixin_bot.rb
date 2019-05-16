require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'zlib'
require 'mixin_bot'
require 'yaml'

yaml_hash = YAML.load_file('./config.yml')

MixinBot.client_id  = yaml_hash["MIXIN_CLIENT_ID"]
MixinBot.session_id = yaml_hash["MIXIN_SESSION_ID"]
MixinBot.client_secret = yaml_hash["MIXIN_CLIENT_SECRET"]
MixinBot.pin_token   = yaml_hash["MIXIN_PIN_TOKEN"]
MixinBot.private_key = yaml_hash["MIXIN_PRIVATE_KEY"]

access_token = MixinBot.api.access_token("GET","/","")
puts access_token

authorization = format('Bearer %s', access_token)



EM.run {
  ws = Faye::WebSocket::Client.new('wss://blaze.mixin.one/', ["Mixin-Blaze-1"],
    :headers => { 'Authorization' => authorization }
  )

  ws.on :open do |event|
    p [:open]
    ws.send(MixinBot.api.list_pending_message)
  end

  ws.on :message do |event|
    p [:message]
    data = event.data
    msg = MixinBot.api.read_message(data)
    jsmsg =  JSON.parse msg
    # p jsmsg
    # p jsmsg["data"]
    if jsmsg["action"] == "CREATE_MESSAGE" && jsmsg["data"] != nil
      msgid = jsmsg["data"]["message_id"]
      ws.send(MixinBot.api.acknowledge_message_receipt(msgid))
      if jsmsg["data"]["category"] == "PLAIN_TEXT"
        conversation_id = jsmsg["data"]["conversation_id"]
        decoded_msg = Base64.decode64 jsmsg["data"]["data"]
        p decoded_msg
        reply_msg = MixinBot.api.plain_text_message(conversation_id, decoded_msg)
        ws.send(reply_msg)
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
