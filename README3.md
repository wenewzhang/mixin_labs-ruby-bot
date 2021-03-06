# Ruby Bitcoin tutorial based on Mixin Network III: Create Bitcoin wallet, read balance and send Bitcoin
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

We have created a bot to [echo message](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README.md) and [echo Bitcoin](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2.md).

### What you will learn from this chapter
1. How to create Bitcoin wallet
2. How to read Bitcoin balance
3. How to send Bitcoin with zero transaction fee and confirmed in 1 second
4. How to send Bitcoin to other wallet


Pre-request: You should have a Mixin Network app account. Create an account:

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

The function create a RSA key pair automatically, then call Mixin Network to create an account and return all account information, save it to csv file.


Now you need to carefully keep the account information. These information are required to read asset balance and other content of account.
### Create Bitcoin wallet for the Mixin Network account
The Bitcoin  wallet is not generated automatically at same time when we create Mixin Network account. Read Bitcoin asset once to generate a Bitcoin wallet.
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
You can found information about Bitcoin asset in the account. Public key is the Bitcoin deposit address. Full response of read  Bitcoin asset is
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


The API provide many information about Bitcoin asset.
* Deposit address:[public_key]
* Logo: [icon_url]
* Asset name:[name]
* Asset uuid in Mixin network: [asset_key]
* Price in USD from Coinmarketcap.com: [price_usd]
* Least confirmed blocks before deposit is accepted by Mixin network:[confirmations]


### Private key?
Where is Bitcoin private key? The private key is protected by multi signature inside Mixin Network so it is invisible for user. Bitcoin asset can only be withdraw to other address when user provide correct RSA private key signature, PIN code and Session key.

### Not only Bitcoin, but also Ethereum, EOS
The account not only contain a Bitcoin wallet, but also contains wallet for Ethereum, EOS, etc. Full blockchain support [list](https://mixin.one/network/chains). All ERC20 Token and EOS token are supported by the account.

Create other asset wallet is same as create Bitcoin wallet, just read the asset.
#### Mixin Network support cryptocurrencies (2019-02-19)

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

If you read EOS deposit address, the deposit address is composed of two parts: account_name and account tag. When you transfer EOS token to your account in Mixin network, you should fill both account name and memo. The memo content is value of 'account_tag'.
Result of read EOS asset is:
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

### Deposit Bitcoin and read balance
Now you can deposit Bitcoin into the deposit address.

This is maybe too expensive for this tutorial. There is a free and lightening fast solution to deposit Bitcoin: add the address in your Mixin messenger account withdrawal address and withdraw small amount Bitcoin from your account to the address. It is free and confirmed instantly because they are both on Mixin Network.

Now you can read Bitcoin balance of the account.
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

### Send Bitcoin inside Mixin Network to enjoy instant confirmation and ZERO transaction fee
Any transaction happen between Mixin network account is free and is confirmed in 1 second.

Pre-request: A PIN has been created for account

A PIN is required to send any asset in Mixin Network. Let's create PIN for the account if it is missing.
```ruby
table = CSV.read(WALLET_NAME)
puts table[0][1]
MixinBot.client_id = table[0][3]
MixinBot.session_id = table[0][2]
MixinBot.pin_token = table[0][1]
MixinBot.private_key = table[0][0]
botAssetsInfo = MixinBot.api.read_assets()
p botAssetsInfo
pinInfo = MixinBot.api.update_pin('',DEFAULT_PIN)
p pinInfo
```
#### Send Bitcoin to another Mixin Network account
We can send Bitcoin to our bot through Mixin Messenger, and then transfer Bitcoin from bot to new user.

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

Read bot's Bitcoin balance to confirm the transaction.
Caution: **mixinApiUser** is for the New User!
```ruby
    botAssetsInfo = MixinBot.api.read_assets()
```
### Send Bitcoin to another Bitcoin exchange or wallet
If you want to send Bitcoin to another exchange or wallet, you need to know the destination deposit address, then add the address in withdraw address list of the Mixin network account.

Pre-request: Withdrawal address is added and know the Bitcoin withdrawal fee

#### Add destination address to withdrawal address list
Call createAddress, the ID of address will be returned in result of API and is required soon.
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

end
```

The **14T129GTbXXPGXXvZzVaNLRFPeHXD1C25C** is a Bitcoin wallet address, Output like below, fee is 0.0025738 BTC, The API result contains the withdrawal address ID.                                                   
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


#### Read withdraw fee anytime
```ruby
  addressInfo = MixinBot.api.get_withdraw_address(addressInfo["data"]["address_id"])
  p addressInfo
```

#### Send Bitcoin to destination address
Submit the withdrawal request to Mixin Network, the withdrawAddress.address_id is the address id return by createAddress
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
#### Confirm the transaction in blockchain explore

[Full source code](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)
