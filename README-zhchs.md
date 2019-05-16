# 基于Mixin Network的Ruby比特币开发教程
![](https://github.com/wenewzhang/mixin_labs-php-bot/raw/master/Bitcoin_php.jpg)
[Mixin Network](https://mixin.one) 是一个免费的 极速的端对端加密数字货币交易系统.
在本章中，你可以按教程在Mixin Messenger中创建一个bot来接收用户消息, 学到如何给机器人转**比特币** 或者 让机器人给你转**比特币**.

[Mixin network 资源汇总](https://github.com/awesome-mixin-network/index_of_Mixin_Network_resource)

## 课程简介
1. [创建一个机器人](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README-zhchs.md)

## 创建一个接受消息的机器人
通过本教程，你将学会如何用Ruby创建一个机器人APP,让它能接受消息.

### Ruby 环境安装:
本教程的程序基于 **Ruby** 开发.

On macOS
```bash
brew update
brew install rbenv
rbenv install 2.6.3
rbenv shell 2.6.3
```

On Ubuntu
```bash
sudo apt update
sudo apt install git curl libssl-dev libreadline-dev zlib1g-dev autoconf  \
bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash -

echo 'export PATH=/root/.rbenv/bin:$PATH' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 2.6.3
rbenv shell 2.6.3
```

检查安装情况！

```bash
wenewzha:~ wenewzhang$ rbenv shell 2.6.3
wenewzha:minecraft wenewzhang$ ruby -v
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
```

### 安装依赖包
本教程依赖 **faye-websocket**  与 **mixin_bot**.

```bash
gem install faye-websocket
gem install mixin_bot
```

### 创建你的项目
到你的工作文档中，创建一个目录，并取一个名字，比如:**mixin_labs-ruby-bot**
```bash
mkdir mixin_labs-ruby-bot
mixin_labs-ruby-bot
```

### 创建第一个机器人APP
按下面的提示，到mixin.one创建一个APP[tutorial](https://mixin-network.gitbook.io/mixin-network/mixin-messenger-app/create-bot-account).

### 生成相应的参数
记下这些[生成的参数](https://mixin-network.gitbook.io/mixin-network/mixin-messenger-app/create-bot-account#generate-secure-parameter-for-your-app)
它们将用于config.yml中.

![mixin_network-keys](https://github.com/wenewzhang/mixin_labs-php-bot/raw/master/mixin_network-keys.jpg)
在项目目录下，创建config.yml,将生成的参数，替换成你的！
> config.yml
`> config.yml
```ruby
MIXIN_CLIENT_ID: 'a1ce2967-a534-417d-bf12-c86571e4eefa'
MIXIN_CLIENT_SECRET: 'a3f52f6c417f24bfdf583ed884c5d0cb489320c58222b061298e4a2d41a1bbd7'
MIXIN_DEFAULT_SCOPE: 'PROFILE:READ+PHONE:READ+ASSETS:READ'
MIXIN_PIN_CODE: '457965'
MIXIN_SESSION_ID: '26ed1f52-a3b4-4cc3-840f-469d3f19b10b'
MIXIN_PIN_TOKEN: '0t4EG7tJerZYds7N9QS0mlRPCYsEVTQBe9iD1zNBCFN/XO7XEB87ypsCDWfRmDiZ7izzB/nokuMJEu6RJShMHCdIwYISU9xckA/8hIsRVydvoP14G/9kRidMHl/3RPLDMK6U2yCefo2BH0kQdbcRDxpiddqrMc4fYmZo6UddU/A='
MIXIN_PRIVATE_KEY: |
  -----BEGIN RSA PRIVATE KEY-----
  MIICXAIBAAKBgQDaSPE8Cu18xzr8MOcgJx8tQnRdlS7c6JVs23497IGdIybIUYmZ
  8zvgrFozpGjQYz2ayRDMWUQd/wm7e0Tf7n4bVCmQfkk72usAHX6pNA4HUeTeTmDT
  sZQKdVx0K84Y3u512cAi5artnUjIsFRPP/LhAX0ujdgNMWIcHrMRh77s1wIDAQAB
  AoGAVPW3Dwuhy8MvriDKlLUlaVRIPnRmPQ05u5ji1e9Ls4GPAsDZsdX+JEBxC1Ce
  ix1VSP2hUCgeXx55B0O/VvlYk0pfogrxDgOw2dP04uboMG7tSE4TZK8J9zFPUrE0
  wizFmbkgV2OEw33r00FqEhr0KnB9kXOzB5BvKN/FVyXui+ECQQDz1x3hOypW2kM9
  uOqjQyg55VDkkXVZ8RgOmVd24MfkDjRauj1oGgLUWvINzhmXN5m84IhlOz1hgEuO
  enHOpMmDAkEA5SuVeRhBZofUoaRbFxWL4jAN6+uuxFxZ0gCc9l4gwFkQp0RbEw/S
  tiX9Cl06JR2oc2FBlaO5Vi1u8XfxOSUzHQJBANijfKaJHFrB3A/QZJbcqbaWaEJK
  gYqBSzBdSHoTx0R04krhQIFm6rCkhH2DaPUSrwJCMqxN74DarUZOvyIrAeUCQH2F
  ecFx/6BhFZ3Tn/Ds5ElneLiXxonW63uSymZG+DlijzSOxDOUnx0VgZuDpK1fqTxJ
  MNr9ai5BhFrOD1n1fiECQBafDxsfFQv3w6j5/2PL54DhddGo50FzGxYR1LlttdVI
  Q04EytqK7grDDS9PsfeXqdUo0D3NMSJ0BYs/kDsqGSc=
  -----END RSA PRIVATE KEY-----
```

需要替换的参数包括： client_id, client_secret, and the pin, pin token, session_id, private key.

### 经典的Hello world
websocket_mixin_bot.rb
```ruby
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
```

Mixin Messenger支持的消息类型很多，具体可到下面链接查看:  [WebSocket消息类型](https://developers.mixin.one/api/beta-mixin-message/websocket-messages/).

每接收到一个消息，需要按消息编号(message_id)给服务器回复一个"已读"的消息,避免服务器在机器人重新登入后，再次发送处理过的消息！
```ruby
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
```
### 完成
现在你的机器人APP运行起来了，你打算如何改造你的机器人呢？

完整的代码[在这儿](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/websocket_mixin_bot.rb)

### 下一课[机器人接收与处理加密货币](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2-zhchs.md)
