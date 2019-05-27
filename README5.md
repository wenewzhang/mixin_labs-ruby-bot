# How to list bitcoin order through Ruby
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

Exincore is introduced in [last chapter](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README4.md), you can exchange many crypto asset at market price and receive your asset in 1 seconds. If you want to trade asset at limited price, or trade asset is not supported by ExinCore now, OceanOne is the answer.
## Solution Two: List your order on Ocean.One exchange
[Ocean.one](https://github.com/mixinNetwork/ocean.one) is a decentralized exchange built on Mixin Network, it's almost the first time that a decentralized exchange gain the same user experience as a centralized one.

You can list any asset on OceanOne. Pay the asset you want to sell to OceanOne account, write your request in payment memo, OceanOne will list your order to market. It send asset to your wallet after your order is matched.

* No sign up required
* No deposit required
* No listing process.

### Pre-request:
You should  have created a bot based on Mixin Network. Create one by reading [Nodejs Bitcoin tutorial](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README.md).

#### Install required packages
This tutorial dependent **msgpack5** and **mixin-node-client**  , [chapter 4](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README4.md), assume them had installed before.

#### Deposit USDT or Bitcoin into your Mixin Network account and read balance
The Ocean.one can match any order. Here we exchange between USDT and Bitcoin, Check the wallet's balance & address before you make order.

- Check the address & balance, find it's Bitcoin wallet address.
- Deposit Bitcoin to this Bitcoin wallet address.
- Check Bitcoin balance after 100 minutes later.

**Omni USDT address is same as Bitcoin address**

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

#### Read orders book from Ocean.one
How to check the coin's price? You need understand what is the base coin. If you want buy Bitcoin and sell USDT, the USDT is the base coin. If you want buy USDT and sell Bitcoin, the Bitcoin is the base coin.

```ruby
if ocmd == "1"
  Utils.OceanOneMarketPriceRequest(BTC_ASSET_ID, USDT_ASSET_ID)
end
def self.OceanOneMarketPriceRequest(asset_id, base_asset_id)
   full_url = "https://events.ocean.one/markets/" + asset_id + "-" + base_asset_id + "/book"
   data = HTTP.get(full_url).body
   body = ""
   redData = data.readpartial
   while  redData != nil
     body = body + redData
     redData = data.readpartial
   end
   result = ActiveSupport::JSON.decode(body).with_indifferent_access
   result["data"]["data"]["asks"].each { |x|
                                          puts x["side"] + " " + x["price"] + " " +
                                          x["amount"] + " " + x["funds"]
                                        }
   result["data"]["data"]["bids"].each { |x|
                                          puts x["side"] + " " + x["price"] + " " +
                                          x["amount"] + " " + x["funds"]
                                        }
end
```

#### Create a memo to prepare order
The chapter two: [Echo Bitcoin](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2.md) introduce transfer coins. But you need to let Ocean.one know which coin you want to buy.
- **side** "B" or "A", "B" for buy, "A" for Sell.
- **targetAsset** UUID of the asset you want to buy
- **price** If Side is "B", Price is AssetUUID; if Side is "A", Price is the asset which transfer to Ocean.one.

```ruby
def self.GenerateOceanMemo(targetAsset,side,price)
  memo = Base64.encode64(MessagePack.pack({
  'A' => UUID.parse(targetAsset).to_raw,
  'S' => side,
  'P' => price,
  'T' => "L"
  }))
  return memo.sub("\n","")
end
```

The code show you how to buy BTC：
```ruby
if ocmd == "b1"
  p "Input the price of BTC/USDT: "
  bprice = gets.chomp
  p "Input the amount of USDT: "
  amount = gets.chomp
  memo = Utils.GenerateOceanMemo(BTC_ASSET_ID,"B",bprice)
  p memo
  assetsInfo = walletAccount.read_asset(USDT_ASSET_ID)
  if assetsInfo["data"]["balance"].to_f >= 1 && assetsInfo["data"]["balance"].to_f >= amount.to_f
    transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                      {
                                        asset_id: USDT_ASSET_ID,
                                        opponent_id: OCEANONE_BOT,
                                        amount: amount,
                                        trace_id: SecureRandom.uuid,
                                        memo: memo
                                      })
    p transInfo
    p "The Order id is " + transInfo["data"]["trace_id"] + " It's needed by cancel-order!"
  else
    p "Not enough USDT"
  end
end
```

#### Pay XIN to OceanOne with generated memo
Transfer XIN(XIN_ASSET_ID) to Ocean.one(OCEANONE_BOT), put you target asset uuid(USDT) in the memo.
```ruby
if ocmd == "s1"
  p "Input the price of BTC/USDT: "
  bprice = gets.chomp
  p "Input the amount of BTC: "
  amount = gets.chomp
  memo = Utils.GenerateOceanMemo(USDT_ASSET_ID,"A",bprice)
  p memo
  assetsInfo = walletAccount.read_asset(BTC_ASSET_ID)
  if assetsInfo["data"]["balance"].to_f > 0 && assetsInfo["data"]["balance"].to_f >= amount.to_f
    transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                      {
                                        asset_id: BTC_ASSET_ID,
                                        opponent_id: OCEANONE_BOT,
                                        amount: amount,
                                        trace_id: SecureRandom.uuid,
                                        memo: memo
                                      })
    p transInfo
    p "The Order id is " + transInfo["data"]["trace_id"] + " It's needed by cancel-order!"
  else
    p "Not enough BTC"
  end
end
```

A success order output like below:

```bash
Make your choose(eg: q for Exit!):
b1
"Input the price of BTC/USDT: "
7777
"Input the amount of USDT: "
1
"hKFBxBDG0McoJiRCm44N2dGbZZL6oVOhQqFQpDc3NzehVKFM"
{"data"=>{"type"=>"transfer", "snapshot_id"=>"10178f11-4e05-4076-b7c9-006e95919a1b",
"opponent_id"=>"aaff5bef-42fb-4c9f-90e0-29f69176b7d4", "asset_id"=>"815b0b1a-2764-3736-8faa-42d694fa620a",
"amount"=>"-1", "trace_id"=>"89025aab-598f-43e5-834a-2feaa01797ff",
"memo"=>"hKFBxBDG0McoJiRCm44N2dGbZZL6oVOhQqFQpDc3NzehVKFM", "created_at"=>"2019-05-27T06:53:07.135709255Z", "counter_user_id"=>"aaff5bef-42fb-4c9f-90e0-29f69176b7d4"}}
"The Order id is 89025aab-598f-43e5-834a-2feaa01797ff It's needed by cancel-order!"
```

## Cancel the Order
To cancel order, just pay any amount of any asset to OceanOne, and write trace_id into memo. Ocean.one take the trace_id as the order id, for example, **89025aab-598f-43e5-834a-2feaa01797ff** is a order id,
We can use it to cancel the order.

```ruby
if ocmd == "c"
  p "Input the Order ID: "
  orderid = gets.chomp
  memo1 = Base64.encode64(MessagePack.pack({
  'O' => UUID.parse(orderid).to_raw
  }))
  memo = memo1.sub("\n","")
  assetsInfo = walletAccount.read_asset(CNB_ASSET_ID)
  if assetsInfo["data"]["balance"].to_f > 0
    transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                      {
                                        asset_id: CNB_ASSET_ID,
                                        opponent_id: OCEANONE_BOT,
                                        amount: "0.00000001",
                                        trace_id: SecureRandom.uuid,
                                        memo: memo
                                      })
    p transInfo
  else
    p "Not enough CNB!"
  end
end
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

- [x] **ruby bitcoin-wallet-ruby.rb** run it.

Commands list of this source code:

- 1: Fetch BTC/USDT Order Book
- 2: Fetch XIN/USDT Order Book
- 3: Fetch ERC20/USDT Order Book
- s1: Sell BTC/USDT
- b1: Buy BTC/USDT
- s2: Sell XIN/USDT
- b2: Buy XIN/USDT
- s3: Sell ERC20/USDT
- s3: Buy ERC20/USDT
- c: Cancel the order
- q: Exit
Make your choose(eg: q for Exit!):

[Full source code](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin-wallet-ruby.rb)
