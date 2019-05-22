# 基于Mixin Network的 Ruby 比特币开发教程: 创建比特币钱包
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

我们已经创建过一个[回复消息](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README-zhchs.md)的机器人和一个能自动[支付比特币](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2-zhchs.md)的机器人.

### 通过本教程的学习，你可以学到如下内容
1. 如何创建一个比特币钱包.
2. 如何读取比特币钱包的余额.
3. 如何支付比特币并即时确认.
4. 如何将Mixin Network的比特币提现到你的冷钱包或第三方交易所.


前期准备：你要有一个Mixin Network账户。下面的代码创建一个帐号，并写到csv文件里。
```ruby
if File.file?(WALLET_NAME)
  p "mybitcoin_wallet.csv has already existed !"
  next
end
yaml_hash = YAML.load_file('./config.yml')

MixinBot.client_id  = yaml_hash["MIXIN_CLIENT_ID"]
MixinBot.session_id = yaml_hash["MIXIN_SESSION_ID"]
MixinBot.client_secret = yaml_hash["MIXIN_CLIENT_SECRET"]
MixinBot.pin_token   = yaml_hash["MIXIN_PIN_TOKEN"]
MixinBot.private_key = yaml_hash["MIXIN_PRIVATE_KEY"]

access_token = MixinBot.api.access_token("GET","/","")

rsa_key = OpenSSL::PKey::RSA.new(1024)
private_key = rsa_key.to_pem()
p private_key
public_key = rsa_key.public_key.to_pem
secret_client = public_key.sub("-----BEGIN PUBLIC KEY-----\n","").sub("\n-----END PUBLIC KEY-----\n","")
reqInfo = MixinBot.api.create_user("ruby bot",secret_client)
p reqInfo["data"]["pin_token"]
p reqInfo["data"]["user_id"]
p reqInfo["data"]["session_id"]


CSV.open(WALLET_NAME, "wb") do |csv|
  csv << [private_key, reqInfo["data"]["pin_token"], reqInfo["data"]["session_id"], reqInfo["data"]["user_id"]]
end
```
上面的语句会在本地创建一个RSA密钥对，然后调用Mixin Network来创建帐号，最后保存帐号信息到csv文件.

现在你需要小心保管好你的帐号信息，在读取该账户的比特币资产余额或者进行其他操作时，将需要用到这些信息.
### 给新建的帐号创建一个比特币钱包
新账号并不默认内置比特币钱包， 现在读一下比特币余额就可以创建一个比特币钱包。
```ruby
if cmd == "2"
  table = CSV.read(WALLET_NAME)
  MixinBot.client_id = table[0][3]
  MixinBot.session_id = table[0][2]
  MixinBot.pin_token = table[0][1]
  MixinBot.private_key = table[0][0]
  botAssetsInfo = MixinBot.api.read_asset(BTC_ASSET_ID)
  p botAssetsInfo
  p "The BTC wallet address is " + botAssetsInfo["data"]["public_key"]
  p "The BTC wallet balance is " + botAssetsInfo["data"]["balance"]
end
```
创建的帐号的比特币资产详细信息如下，其中public key就是比特币的存币地址:
```bash
Make your choose(eg: q for Exit!):
2
{"data"=>{"type"=>"asset", "asset_id"=>"c6d0c728-2624-429b-8e0d-d9d19b6592fa",
"chain_id"=>"c6d0c728-2624-429b-8e0d-d9d19b6592fa", "symbol"=>"BTC",
 "name"=>"Bitcoin", "icon_url"=>"https://images.mixin.one/HvYGJsV5TGeZ-X9Ek3FEQohQZ3fE9LBEBGcOcn4c4BNHovP4fW4YB97Dg5LcXoQ1hUjMEgjbl1DPlKg1TW7kK6XP=s128",
 "balance"=>"0", "public_key"=>"1MQLQG1FshdVaQrDE36FLGabCitE3vPUA", "account_name"=>"",
 "account_tag"=>"", "price_btc"=>"1", "price_usd"=>"7948.30287759", "change_btc"=>"0",
 "change_usd"=>"0.006197123302394101", "asset_key"=>"c6d0c728-2624-429b-8e0d-d9d19b6592fa",
 "confirmations"=>6, "capitalization"=>0}}
"The BTC wallet address is 1MQLQG1FshdVaQrDE36FLGabCitE3vPUA"
"The BTC wallet balance is 0"
-------------------------------------------------------------------------
```

这个API能够提供若干与比特币有关的信息:
* 存币地址:[public_key]
* Logo: [icon_url]
* 资产名字:[name]
* 资产在Mixin Network的uuid: [asset_key]
* 对美元的价格(Coinmarketcap.com提供): [price_usd]
* 存币时确认的区块数量:[confirmations]


### 比特币私钥呢？
比特币的私钥呢？这个私钥被Mixin Network通过多重签名保护，所以对用户来说是不可见的,比特币资产的提现和转账都需要用户提供正确的的RSA签名,PIN代码与会话密钥才能完成.

### 不只是比特币，还有以太坊，EOS等
这个帐号不只支持比特币，还支持以太坊，EOS等, 完整的区块链支持[列表](https://mixin.one/network/chains). 这个账户同时也支持所有的 ERC20 代币与 EOS 代币.

创建其它的币的钱包与创建比特币钱包过程一样，读对应的资产余额就可以.

#### Mixin Network 当前支持的加密货币 (2019-02-19)

|crypto |uuid in Mixin Network
|---|---
|EOS|6cfe566e-4aad-470b-8c9a-2fd35b49c68d
|CNB|965e5c6e-434c-3fa9-b780-c50f43cd955c
|BTC|c6d0c728-2624-429b-8e0d-d9d19b6592fa
|ETC|2204c1ee-0ea2-4add-bb9a-b3719cfff93a
|XRP|23dfb5a5-5d7b-48b6-905f-3970e3176e27
|XEM|27921032-f73e-434e-955f-43d55672ee31
|ETH|43d61dcd-e413-450d-80b8-101d5e903357
|DASH|6472e7e3-75fd-48b6-b1dc-28d294ee1476
|DOGE|6770a1e5-6086-44d5-b60f-545f9d9e8ffd
|LTC|76c802a2-7c88-447f-a93e-c29c9e5dd9c8
|SC|990c4c29-57e9-48f6-9819-7d986ea44985
|ZEN|a2c5d22b-62a2-4c13-b3f0-013290dbac60
|ZEC|c996abc9-d94e-4494-b1cf-2a3fd3ac5714
|BCH|fd11b6e3-0b87-41f1-a41f-f0e9b49e5bf0

EOS的存币地址与其它的币有些不同，它由两部分组成： account_name and account tag, 如果你向Mixin Network存入EOS，你需要填两项数据： account name 是**eoswithmixin**,备注里输入你的account_tag,比如**0aa2b00fad2c69059ca1b50de2b45569**.

EOS的资产余额返回结果如下:
```bash
Make your choose(eg: q for Exit!):
3
{"data"=>{"type"=>"asset", "asset_id"=>"6cfe566e-4aad-470b-8c9a-2fd35b49c68d",
 "chain_id"=>"6cfe566e-4aad-470b-8c9a-2fd35b49c68d", "symbol"=>"EOS",
  "name"=>"EOS", "icon_url"=>"https://images.mixin.one/a5dtG-IAg2IO0Zm4HxqJoQjfz-5nf1HWZ0teCyOnReMd3pmB8oEdSAXWvFHt2AJkJj5YgfyceTACjGmXnI-VyRo=s128",
   "balance"=>"0", "public_key"=>"", "account_name"=>"eoswithmixin",
   "account_tag"=>"60ec682616408d9486b5975a1361e269", "price_btc"=>"0.00079077",
   "price_usd"=>"6.28647972", "change_btc"=>"0.004235601507246285",
   "change_usd"=>"0.00974554134353926", "asset_key"=>"eosio.token:EOS",
   "confirmations"=>64, "capitalization"=>0}}
"The EOS wallet address is eoswithmixin 60ec682616408d9486b5975a1361e269"
"The EOS wallet balance is 0"
-------------------------------------------------------------------------
```

### 存入比特币与读取比特币余额
现在，你可以向比特币的钱包存币了。

当然，在比特币网络里转币，手续费是相当贵的，费用的中位数在0.001BTC,按当前4000美元的价格，在4美元左右，有一个方便的办法，如果你有[Mixin Messenger](https://mixin.one/messenger)帐号，里面并且有比特币的话，可以直接提现比特币到新创建的帐号的比特币充值地址，它们在同一个Mixin Network网络内，手续费为0，而且1秒到账。

下面的代码，可以读取比特币钱包余额.
```ruby
table = CSV.read(WALLET_NAME)
MixinBot.client_id = table[0][3]
MixinBot.session_id = table[0][2]
MixinBot.pin_token = table[0][1]
MixinBot.private_key = table[0][0]
botAssetsInfo = MixinBot.api.read_asset(BTC_ASSET_ID)
p botAssetsInfo
p "The BTC wallet address is " + botAssetsInfo["data"]["public_key"]
p "The BTC wallet balance is " + botAssetsInfo["data"]["balance"]
```
### Mixin Network网内免手续费的，并且即时确认
任何币在Mixin Network内部的交易，都是无手续费的，并且立刻到账。
前期准备： 账户设置了PIN

对于新创建的帐号，我们通过updatePin来设置新PIN码, 代码如下：
```ruby
table = CSV.read(WALLET_NAME)
puts table[0][1]
MixinBot.client_id = table[0][3]
MixinBot.session_id = table[0][2]
MixinBot.pin_token = table[0][1]
MixinBot.private_key = table[0][0]
pinInfo = MixinBot.api.update_pin('',DEFAULT_PIN)
p pinInfo
```
#### Mixin Network帐号之间的比特币支付
通过Mixin Messenger，我们可以先转比特币给机器人，然后让机器人转币给新用户。
```ruby
if cmd == "teb"
  yaml_hash = YAML.load_file('./config.yml')

  MixinBot.client_id  = yaml_hash["MIXIN_CLIENT_ID"]
  MixinBot.session_id = yaml_hash["MIXIN_SESSION_ID"]
  MixinBot.client_secret = yaml_hash["MIXIN_CLIENT_SECRET"]
  MixinBot.pin_token   = yaml_hash["MIXIN_PIN_TOKEN"]
  MixinBot.private_key = yaml_hash["MIXIN_PRIVATE_KEY"]
  table = CSV.read(WALLET_NAME)
  wallet_userid = table[0][3]
  botAssetsInfo = MixinBot.api.read_asset(EOS_ASSET_ID)
  if botAssetsInfo["data"]["balance"].to_f > 0
    transInfo = MixinBot.api.create_transfer(MixinBot.api.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                      {
                                        asset_id: EOS_ASSET_ID,
                                        opponent_id: wallet_userid,
                                        amount: botAssetsInfo["data"]["balance"],
                                        trace_id: SecureRandom.uuid,
                                        memo: "from ruby"
                                      })
    p transInfo
 end
end
```

读取Bitcoin的余额，来确认比特币是不是转成功了！
```ruby
    botAssetsInfo = MixinBot.api.read_assets()
```
### 如何将比特币存入你的冷钱包或者第三方交易所
如果你希望将币存入你的冷钱包或者第三方交易所, 先要得到冷钱包或者你在第三方交易所的钱包地址，然后将钱包地址提交到Mixin Network.

- **要点提示**: 提现是需要支付收续费的,准备好比特币包地址!

#### 增加目的钱包地址到Mixin Network
调用createAddress API, 将会返回一个address_id,下一步的提现操作会用到这个id。
```ruby
if cmd == "wb"
  table = CSV.read(WALLET_NAME)
  MixinBot.client_id = table[0][3]
  MixinBot.session_id = table[0][2]
  MixinBot.pin_token = table[0][1]
  MixinBot.private_key = table[0][0]
  addressInfo = MixinBot.api.create_withdraw_address(BTC_ASSET_ID,
                                                       DEFAULT_PIN,
                                                       BTC_WALLET_ADDR,
                                                       "","",
                                                       "from ruby")
  p addressInfo
  p "The address id is " + addressInfo["data"]["address_id"] + " it is needed by read fee!"
end
```

这里的 **14T129GTbXXPGXXvZzVaNLRFPeHXD1C25C** 就是一个比特币钱包地址, 如下所示，提现费用是0.0025738 BTC, address_id  是"345855b5-56a5-4f3b-ba9e-d99601ef86c1".                                                   

```bash
Make your choose:wb
wb
{"type":"address","address_id":"58860d12-cbdc-40ae-8a4a-b0fc72f418b3",
"asset_id":"c6d0c728-2624-429b-8e0d-d9d19b6592fa","public_key":"14T129GTbXXPGXXvZzVaNLRFPeHXD1C25C",
"label":"hi","account_name":"","account_tag":"","fee":"0.00118846","reserve":"0","dust":"0.0001",
"updated_at":"2019-04-16T06:12:15.686517454Z"}
------------------------BTC---Withdrawal---Information---------------------------
The BTC Witchdrawal address is 14T129GTbXXPGXXvZzVaNLRFPeHXD1C25C
The BTC withdraw fee  is 0.00118846
```


#### 创建提现地址成功后，你可以用readAddress读取最新的提现费。
```ruby
  addressInfo = MixinBot.api.get_withdraw_address(addressInfo["data"]["address_id"])
  p addressInfo
```

#### 提交提现请求，Mixin Network会即时处理提现请求.
提交提现请求到 Mixin Network, withdrawAddress.address_id 就是createAddress创建的。
```ruby
if cmd == "wb"
  table = CSV.read(WALLET_NAME)
  MixinBot.client_id = table[0][3]
  MixinBot.session_id = table[0][2]
  MixinBot.pin_token = table[0][1]
  MixinBot.private_key = table[0][0]
  addressInfo = MixinBot.api.create_withdraw_address(BTC_ASSET_ID,
                                                       DEFAULT_PIN,
                                                       BTC_WALLET_ADDR,
                                                       "","",
                                                       "from ruby")
  p addressInfo
  p "The address id is " + addressInfo["data"]["address_id"] + " it is needed by read fee!"
  addressInfo2 = MixinBot.api.del_withdraw_address(addressInfo["data"]["address_id"], DEFAULT_PIN)
  p addressInfo2

  withdrawInfo = MixinBot.api.withdrawals(addressInfo["data"]["address_id"],
                                          DEFAULT_PIN,
                                          "0.1",
                                          SecureRandom.uuid,"from ruby")
  p withdrawInfo
end
```

#### 可以通过blockchain explore来查看进度.

[完整的代码在这儿](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)
