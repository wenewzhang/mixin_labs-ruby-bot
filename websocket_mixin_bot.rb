require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'zlib'
require '../mixin_bot/lib/mixin_bot'
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
    p jsmsg
    # p jsmsg["data"]
    if jsmsg["action"] == "CREATE_MESSAGE" && jsmsg["data"] != nil
      msgid = jsmsg["data"]["message_id"]
      ws.send(MixinBot.api.acknowledge_message_receipt(msgid))
      if jsmsg["data"]["category"] == "PLAIN_TEXT"
        conversation_id = jsmsg["data"]["conversation_id"]
        decoded_msg = Base64.decode64 jsmsg["data"]["data"]
        p decoded_msg
        if decoded_msg == "?" or decoded_msg == "h" or decoded_msg == "H"
          reply_msg = "?: help\n" + "1: Payment link for APP_CARD\n" + "2: Payment link for APP_BUTTON_GROUP\n"
          reply_msg = MixinBot.api.plain_text_message(conversation_id,reply_msg)
          ws.send(reply_msg)
        elsif (decoded_msg == "1")
          payLinkEOS = "https://mixin.one/pay?recipient=" +
             "a1ce2967-a534-417d-bf12-c86571e4eefa" + "&asset=" +
             "6cfe566e-4aad-470b-8c9a-2fd35b49c68d" +
             "&amount=0.001" + "&trace=" + SecureRandom.uuid +
             "&memo="
          msgData = {
                       'icon_url':"https://mixin.one/assets/98b586edb270556d1972112bd7985e9e.png",
                       'title':"Pay 0.001 EOS",
                       'description':"pay",
                       'action':payLinkEOS
                     }
          ws.send(MixinBot.api.
                  app_card_message(conversation_id,
                                    msgData))
        elsif decoded_msg == "2"
          payLinkEOS = "https://mixin.one/pay?recipient=" +
             "a1ce2967-a534-417d-bf12-c86571e4eefa" + "&asset=" +
             "6cfe566e-4aad-470b-8c9a-2fd35b49c68d" +
             "&amount=0.001" + "&trace=" + SecureRandom.uuid +
             "&memo="

          payLinkEOS = "https://mixin.one/pay?recipient=" +
             MixinBot.client_id + "&asset=" +
             "6cfe566e-4aad-470b-8c9a-2fd35b49c68d" +
             "&amount=0.001" + "&trace=" + SecureRandom.uuid +
             "&memo="
          payLinkBTC = "https://mixin.one/pay?recipient=" +
                       MixinBot.client_id + "&asset=" +
                       "c6d0c728-2624-429b-8e0d-d9d19b6592fa" +
                       "&amount=0.0001" + "&trace=" + SecureRandom.uuid +
                       "&memo="
          button1 = {
                    label: "Pay 0.001 EOS",
                    color:  "#FFABAB",
                    action: payLinkEOS
                    }
          button2 = {
                    label: "Pay 0.0001 BTC",
                    color:  "#00EEFF",
                    action: payLinkBTC
                    }
          buttons = [button1,button2]
          ws.send(MixinBot.api.
                      app_button_group_message(conversation_id,
                                              jsmsg["data"]["user_id"],
                                              buttons))
           p "send app button group"
        else
          reply_msg = MixinBot.api.plain_text_message(conversation_id,decoded_msg)
          ws.send(reply_msg)
        end
      end
      if jsmsg["data"]["category"] == "SYSTEM_ACCOUNT_SNAPSHOT"
        jsdata =  JSON.parse (Base64.decode64(jsmsg["data"]["data"]))
        p jsdata["amount"]
        if jsdata["amount"].to_f > 0
          p "The Bot got coins:" + jsdata["amount"]
          transInfo = MixinBot.api.create_transfer(MixinBot.api.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                            {
                                              asset_id: jsdata["asset_id"],
                                              opponent_id: jsdata["opponent_id"],
                                              amount: jsdata["amount"],
                                              trace_id: SecureRandom.uuid,
                                              memo: "from ruby"
                                            })
           p transInfo
        end
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
