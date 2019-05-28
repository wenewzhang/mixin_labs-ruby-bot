# How to list any ERC20 token on decentralized market through Ruby
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

OceanOne is introduced in [last chapter](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README5.md), you can trade Bitcoin. All kinds of crypto asset on Mixin Network can be listed on OceanOne.All ERC20 token and EOS token can be listed. Following example will show you how to list a ERC20 token. You can list other token after read the tutorial.

There is a [ERC20 token](https://etherscan.io/token/0xc409b5696c5f9612e194a582e14c8cd41ecdbc67) called Benz. It is deposited into Mixin Network. You can search all transaction history from [Mixin Network browser](https://mixin.one/snapshots/2b9c216c-ef60-398d-a42a-eba1b298581d )

### Pre-request:
Deposit some coin to your wallet, and then use **getAssets** API fetch the asset UUID which Mixin Network gave it.

### Get the ERC-20 compliant coin UUID
The **getAssets** API return json data, for example:

- **asset_id** UUID of this coin
- **public_key** The wallet address for this coin
- **symbol**  Coin name, Eg: Benz.

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
The detail information of **getAssets** is output like below:
```bash
Make your choose:aw
run...
client id is:26b20aa5-40c0-3e00-9de0-666cfb6f2daa
Benz   2b9c216c-ef60-398d-a42a-eba1b298581d   799   0x9A4F6c67444cd6558905ef5B04a4c429b9538A9d
EOS   6cfe566e-4aad-470b-8c9a-2fd35b49c68d   0
CNB   965e5c6e-434c-3fa9-b780-c50f43cd955c   4.72599997   0x9A4F6c67444cd6558905ef5B04a4c429b9538A9d
BTC   c6d0c728-2624-429b-8e0d-d9d19b6592fa   0   17z1Rq3VsyvvXvGWiHT8YErjBoFgnhErB8
XIN   c94ac88f-4671-3976-b60a-09064f1811e8   0.01   0x9A4F6c67444cd6558905ef5B04a4c429b9538A9d
```
### Make the limit order
- **Limit Order to Buy**  at or below the market.
- **Limit Order to Sell**  at or above the market.

OceanOne support three base coin: USDT, XIN, BTC, that mean you can sell or buy it between USDT, XIN, BTC, so, you have there order: Benz/USDT, Benz/XIN, Benz/BTC, here show you how to make the sell order with USDT.

### Make the limit order to sell.


```ruby
if ocmd == "s3"
  p "Input the price of ERC/USDT: "
  bprice = gets.chomp
  p "Input the amount of ERC20_BENZ: "
  amount = gets.chomp
  memo = Utils.GenerateOceanMemo(USDT_ASSET_ID,"A",bprice)
  p memo
  assetsInfo = walletAccount.read_asset(ERC20_BENZ)
  if assetsInfo["data"]["balance"].to_f > 0 && assetsInfo["data"]["balance"].to_f >= amount.to_f
    transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                      {
                                        asset_id: ERC20_BENZ,
                                        opponent_id: OCEANONE_BOT,
                                        amount: amount,
                                        trace_id: SecureRandom.uuid,
                                        memo: memo
                                      })
    p transInfo
    p "The Order id is " + transInfo["data"]["trace_id"] + " It's needed by cancel-order!"
  else
    p "Not enough ERC20_BENZ"
  end
end
```

### Make the limit order to buy.
After the order commit, wait 1 minute to let the OceanOne exchange initialize it.
```ruby
if ocmd == "b3"
  p "Input the price of ERC20/USDT: "
  bprice = gets.chomp
  p "Input the amount of USDT: "
  amount = gets.chomp
  memo = Utils.GenerateOceanMemo(ERC20_BENZ,"B",bprice)
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

### Read orders book from Ocean.one
Now, check the orders-book.

```ruby
if ocmd == "3"
  Utils.OceanOneMarketPriceRequest(ERC20_BENZ, USDT_ASSET_ID)
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
### Command of make orders

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

[Full source code](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)
