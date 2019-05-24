# Ruby Bitcoin tutorial based on Mixin Network
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)
A Mixin messenger bot will be created in this tutorial. The bot is powered by Ruby and echo message and Bitcoin from user.

[Mixin network resource](https://github.com/awesome-mixin-network/index_of_Mixin_Network_resource)

## What you will learn from this tutorial
 1. [How to create bot in Mixin messenger and reply message to user](https://github.com/wenewzhang/mixin_labs-ruby-bot#create-bot-and-receive-message-from-user)| [Chinese](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README-zhchs.md)

 2. [How to receive Bitcoin and send Bitcoin in Mixin Messenger](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2.md)| [Chinese](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2-zhchs.md)

 3. [How to create a Bitcoin wallet based on Mixin Network API](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README3.md) | [Chinese](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README3-zhchs.md)

 4. [How to trade bitcoin through Ruby language: Pay to ExinCore](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README4.md) |  [Chinese](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README4-zhchs.md)

## Create bot in Mixin messenger and reply message to user
### Ruby environment setup:
This tutorial is written in Ruby.

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

Following command can be used to check the installation
```bash
wenewzha:~ wenewzhang$ rbenv shell 2.6.3
wenewzha:minecraft wenewzhang$ ruby -v
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
```
### Install the dependent packages
This bot dependent **faye-websocket**  and **mixin_bot**.

```bash
gem install faye-websocket
gem install mixin_bot
```

### Create the project
Go to your documents folder then create a directory, for example: **mixin_labs-ruby-bot**
```bash
mkdir mixin_labs-ruby-bot
mixin_labs-ruby-bot
```

### Create your first app in Mixin Network developer dashboard
You need to create an app in dashboard. This [tutorial](https://mixin-network.gitbook.io/mixin-network/mixin-messenger-app/create-bot-account) can help you.

### Generate parameter of your app in dashboard
After app is created in dashboard, you still need to [generate parameter](https://mixin-network.gitbook.io/mixin-network/mixin-messenger-app/create-bot-account#generate-secure-parameter-for-your-app)
and write down required content, these content will be written into config.yml file.

![mixin_network-keys](https://github.com/wenewzhang/mixin_labs-php-bot/blob/master/mixin_network-keys.jpg)
In project folder, create a file: config.yml. Copy the following content into it.
> config.yml
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
Replace the value with **content generated in dashboard**.

### Hello world in Ruby
Copy the following code into websocket_mixin_bot.rb, create it if it is missing in your folder
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
```

Run the code
```bash
ruby websocket_mixin_bot.rb
```
The following content will be displayed in console if everything works.
```bash
[:open]
[:message]
{"id"=>"2e13092f-4048-488f-82bc-f5ee9f984002", "action"=>"LIST_PENDING_MESSAGES"}
```

Add the bot(for example, this bot id is 7000101639) as your friend in [Mixin Messenger](https://mixin.one/messenger) and send your messages.
![mixin_messenger](https://raw.githubusercontent.com/wenewzhang/mixin_labs-php-bot/master/helloworld.jpeg)

Not only texts, images and other type message will be pushed to your bot. You can find more [details](https://developers.mixin.one/api/beta-mixin-message/websocket-messages/) about Messenger message.

### Source code summary
Send a READ operation message to the server let it knows this message has been read. The bot will receive the duplicated message when the bot connected to server again if bot don't send response.
```ruby
ws.send(MixinBot.api.acknowledge_message_receipt(msgid))
```

### End
Now your bot worked, you can hack it.

Full code is [here](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/websocket_mixin_bot.rb)
