
# 基于Mixin Network的 Ruby 比特币开发教程: 机器人接受比特币并立即退还用户
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

在 [上一篇教程中](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README-zhchs.md), 我们创建了自动回复消息的机器人,当用户发送消息"Hello,World!"时，机器人会自动回复同一条消息!


按本篇教程后学习后完成后，你的机器人将会接受用户发送过来的加密货币，然后立即转回用户。下面是全部源代码，创建一个websocket_mixin_bot.rb试一下吧！

```ruby
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

```
### 你好，我的币!
在工程目录下，执行 **ruby websocket_mixin_bot.rb**

```bash
ruby websocket_mixin_bot.rb
```

```bash
wenewzha:mixin_labs-ruby-bot wenewzhang$ ruby websocket_mixin_bot.rb
[:open]
[:message]
{"id"=>"1003b2b5-b8e4-4b54-bd03-983c61f64869", "action"=>"LIST_PENDING_MESSAGES"}
```

如果控制台出现 "LIST_PENDING_MESSAGES"字样, 连接到mixin.one成功了，正在侦听用户发送消息给它!

![pay-links](https://github.com/wenewzhang/mixin_labs-php-bot/raw/master/pay-links.jpg)

按帮助来操作,发送消息得到相应的支付提示
- **1** 机器人回复 APP_CARD 支付链接.
- **2** 机器人回复 APP_BUTTON_GROUP 支付链接.
- **? or help** : 显示帮助
点击上面的链接，将会弹出一个窗口，输入你的密码，将支付币给机器人!
![click-pay-link-to-pay](https://github.com/wenewzhang/mixin_labs-php-bot/raw/master/click-link-to-pay.jpg)

[Mixin Messenger支持的消息类型](https://developers.mixin.one/api/beta-mixin-message/websocket-messages/)

如下图所示，用户点击支付链接，输入密码，支付0.01 EOS给机器人，机器人马上返还给用户！
![pay-link](https://github.com/myrual/mixin_network-nodejs-bot2/raw/master/Pay_and_refund_quickly.jpg)

亲爱的开发者，你也可以从消息控制面板里，点击转帐，直接将币转给机器人！它还是一样的立即返还！
![transfer and tokens](https://github.com/wenewzhang/mixin_network-nodejs-bot2/raw/master/transfer-any-tokens.jpg)

## 源代码解释

```ruby
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
```
如果机器人收到币，
```ruby
jsdata["amount"]
```
大于零；如果机器人支付币给用户，接收到的消息是一样的，唯一不同的是
```ruby
jsdata["amount"]
```
是一个负数.

```ruby
transInfo = MixinBot.api.create_transfer(MixinBot.api.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                  {
                                    asset_id: jsdata["asset_id"],
                                    opponent_id: jsdata["opponent_id"],
                                    amount: jsdata["amount"],
                                    trace_id: SecureRandom.uuid,
                                    memo: "from ruby"
                                  })
 p transInfo
```
最后一步，调用MixinSDK将币还给用户！

完整的代码在这儿 [here](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/websocket_mixin_bot.rb)
