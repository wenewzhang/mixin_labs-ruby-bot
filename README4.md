# How to trade bitcoin through Ruby language
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

## Solution One: pay to ExinCore API
[Exincore](https://github.com/exinone/exincore) provide a commercial trading API on Mixin Network.

You pay USDT to ExinCore, ExinCore transfer Bitcoin to you on the fly with very low fee and fair price. Every transaction is anonymous to public but still can be verified on blockchain explorer. Only you and ExinCore know the details.

ExinCore don't know who you are because ExinCore only know your client's uuid.

### Pre-request:
You should  have created a bot based on Mixin Network. Create one by reading [Ruby Bitcoin tutorial](https://github.com/wenewzhang/mixin_labs-ruby-bot).

#### Install required packages
As you know, we introduce you the mixin-sdk-php in [chapter 1](https://github.com/wenewzhang/mixin_labs-php-bot/blob/master/README.md), assume it has installed before, let's install **uuid, msgpack** here.
```bash
 gem install msgpack
 gem install easy-uuid
```

#### Deposit USDT or Bitcoin into your Mixin Network account and read balance
ExinCore can exchange between Bitcoin, USDT, EOS, Eth etc. Here show you how to exchange between USDT and Bitcoin,
Check the wallet's balance & address before you make order.

- Check the address & balance, remember it Bitcoin wallet address.
- Deposit Bitcoin to this Bitcoin wallet address.
- Check Bitcoin balance after 100 minutes later.

**By the way, Bitcoin & USDT 's address are the same.**

```ruby
if cmd == "aw"
  assetsInfo = walletAccount.read_assets()
  p "--------The Wallet Assets List-----------------"
  assetsInfo["data"].each { |x| puts x["symbol"] + " " +
                              x["balance"] + " " + x["public_key"] +
                              x["account_name"] + " " + x["account_tag"]}
  p "----------End of Wallet Assets --------------"
end
```

#### Read market price
How to check the coin's price? You need understand what is the base coin. If you want buy Bitcoin and sell USDT, the USDT is the base coin. If you want buy USDT and sell Bitcoin, the Bitcoin is the base coin.
```ruby
if cmd == "8"
  Utils.ExinCoreMarketPriceRequest(USDT_ASSET_ID)
end
if cmd == "9"
  Utils.ExinCoreMarketPriceRequest(BTC_ASSET_ID)
end

def self.ExinCoreMarketPriceRequest(asset_id)
  full_url = "https://exinone.com/exincore/markets?base_asset=" + asset_id
  p full_url
  data = HTTP.get(full_url).body
  body = ""
  redData = data.readpartial
  while  redData != nil
    body = body + redData
    redData = data.readpartial
  end
  result = ActiveSupport::JSON.decode(body).with_indifferent_access
  result["data"].each { |x|
        puts x["exchange_asset_symbol"] +  "/" +  x["base_asset_symbol"] + " " +
             x["price"] + " " + x["minimum_amount"] + " " + x["maximum_amount"] +
             " " + x["exchanges"][0]
      }
end
```

#### Create a memo to prepare order
The chapter two: [Echo Bitcoin](https://github.com/wenewzhang/mixin_labs-php-bot/blob/master/README2.md) introduce transfer coins. But you need to let ExinCore know which coin you want to buy. Just write your target asset into memo.
```ruby
memo1 = Base64.encode64(MessagePack.pack({
'A' => UUID.parse(USDT_ASSET_ID).to_raw
}))
memo = memo1.sub("\n","")
```

#### Pay BTC to API gateway with generated memo
Transfer Bitcoin(BTC_ASSET_ID) to ExinCore(EXIN_BOT), put you target asset uuid in the memo, otherwise, ExinCore will refund you coin immediately!
```ruby
const EXIN_BOT        = "61103d28-3ac2-44a2-ae34-bd956070dab1";
const BTC_ASSET_ID    = "c6d0c728-2624-429b-8e0d-d9d19b6592fa";
const EOS_ASSET_ID    = "6cfe566e-4aad-470b-8c9a-2fd35b49c68d";
const USDT_ASSET_ID   = "815b0b1a-2764-3736-8faa-42d694fa620a";
if cmd == "5"
  memo1 = Base64.encode64(MessagePack.pack({
  'A' => UUID.parse(USDT_ASSET_ID).to_raw
  }))
  memo = memo1.sub("\n","")
  p memo
  transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                    {
                                      asset_id: BTC_ASSET_ID,
                                      opponent_id: EXIN_BOT,
                                      amount: "0.0001",
                                      trace_id: SecureRandom.uuid,
                                      memo: memo
                                    })
   p transInfo
end
```
If you want buy BTC:

```ruby
if cmd == "6"
  memo1 = Base64.encode64(MessagePack.pack({
  'A' => UUID.parse(BTC_ASSET_ID).to_raw
  }))
  memo = memo1.sub("\n","")
  p memo
  transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                    {
                                      asset_id: USDT_ASSET_ID,
                                      opponent_id: EXIN_BOT,
                                      amount: "1",
                                      trace_id: SecureRandom.uuid,
                                      memo: memo
                                    })
   p transInfo
end
```

The ExinCore should transfer the target coin to your bot, meanwhile, put the fee, order id, price etc. information in the memo, unpack the data like below.
- **read_snapshots** Read snapshots of the user.
```ruby
if cmd == "7"
  if wallet_userid == "5e4ad097-21e8-3f6b-98f7-9dc74dd99f77"
    dt = "2019-05-23T09:48:04.582099Z"
  else
    puts "Input the snapshots datetime: "
    dt = gets.chomp
  end
  p CGI.escape(dt)
  snaps = walletAccount.read_snapshots({
                                      limit: "10",
                                      offset: CGI.escape(dt),
                                      asset: BTC_ASSET_ID,
                                      order: "ASC"
                                      })
  snaps["data"].each { |x|
                      if x["amount"].to_f > 0
                        if x["data"] != nil
                          uData = MessagePack.unpack(Base64.decode64(x["data"]))
                          p uData
                          p "The code is " + uData["C"].to_s + " Price is " + uData["P"] + " Fee is " +
                            uData["F"]
                          p "Fee is Asset UUID is " + UUID.parse(uData["FA"]).to_s
                          p "Order id is  " + UUID.parse(uData["O"]).to_s
                        end
                      end
                      }
end
```

If you coin exchange successful, console output like below:
```bash
Make your choose(eg: q for Exit!):
7
"2019-05-23T09%3A48%3A04.582099Z"
{"C"=>1000, "P"=>"7562.91", "F"=>"0.000000264", "FA"=>"\xC6\xD0\xC7(&$B\x9B\x8E\r\xD9\xD1\x9Be\x92\xFA", "T"=>"R", "O"=>"\xC4\x00*\a\xF1\xB1C9\xBC\xCE%\xC3C\x88^R"}
"The code is 1000 Price is 7562.91 Fee is 0.000000264"
"Fee is Asset UUID is c6d0c728-2624-429b-8e0d-d9d19b6592fa"
"Order id is  c4002a07-f1b1-4339-bcce-25c343885e52"
-------------------------------------------------------------------------
```

#### Read Bitcoin balance
Check the wallet's balance.
```ruby
if cmd == "aw"
  assetsInfo = walletAccount.read_assets()
  p "--------The Wallet Assets List-----------------"
  assetsInfo["data"].each { |x| puts x["symbol"] + " " +
                              x["balance"] + " " + x["public_key"] +
                              x["account_name"] + " " + x["account_tag"]}
  p "----------End of Wallet Assets --------------"
end
```
## Source code usage
Execute **ruby bitcoin_wallet-ruby.rb** to run it.

- 1: Create Bitcoin Wallet and update PIN
- 2: Read Bitcoin balance & address
- 3: Read USDT balance & address
- 4: Read EOS balance & address
- tbb:Transfer BTC from Bot to Wallet
- tbm:Transfer BTC from Wallet to Master
- teb:Transfer EOS from Bot to Wallet
- tem:Transfer EOS from Wallet to Master
- tub:Transfer USDT from Bot to Wallet
- tum:Transfer USDT from Wallet to Master
- tcb:Transfer CNB from Bot to Wallet
- tcm:Transfer CNB from Wallet to Master
- 5: Pay 0.0001 BTC to ExinCore buy USDT
- 6: Pay $1 USDT to ExinCore buy BTC
- 7: Read Snapshots
- 8: Fetch market price(USDT)
- 9: Fetch market price(BTC)
- ab: Read Bot Assets
- aw: Read Wallet Assets
- q: Exit
Make your choose(eg: q for Exit!):

[Full source code](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)

## Solution Two: List your order on Ocean.One exchange
