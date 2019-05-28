# 用Ruby在去中心化交易所OceanOne上挂单买卖任意ERC20 token
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

在[上一课](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README5.md)中，我们介绍了如何在OceanOne交易比特币。OceanOne支持交易任何Mixin Network上的token，包括所有的ERC20和EOS token，不需要任何手续和费用，直接挂单即可。下面介绍如何将将一个ERC20 token挂上OceanOne交易！在掌握了ERC20 token之后，就可以把任何token在Ocean上买卖。

此处我们用一个叫做Benz的[ERC20 token](https://etherscan.io/token/0xc409b5696c5f9612e194a582e14c8cd41ecdbc67)为例。这个token已经被充值进Mixin Network，你可以在[区块链浏览器](https://mixin.one/snapshots/2b9c216c-ef60-398d-a42a-eba1b298581d )看到这个token在Mixin Network内部的总数和交易
### 预备知识:
先将Benz币存入你的钱包，然后使用**getAssets** API读取它的UUID.

### 取得该币的UUID
调用 **getAssets** API 会返回json数据, 如:

- **asset_id** 币的UUID.
- **public_key** 该币的当前钱包的地址.
- **symbol**  币的名称. 如: Benz.

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
调用 **read_assets** API的完整输出如下:
```bash
"--------The Wallet Assets List-----------------"
Benz 10.03 0x822664c2EFb27E2Eb4c4286f421B4BF6FB943fC6
ETH 0 0x822664c2EFb27E2Eb4c4286f421B4BF6FB943fC6
EOS 0 eoswithmixin b0adfae2f8828d15e11cb1fbe23d6096
USDT 1 1KB4RbV5W4MNybpjcJjULKNVXubfR5MJqA
CNB 0.99999995 0x822664c2EFb27E2Eb4c4286f421B4BF6FB943fC6
BTC 0 1KB4RbV5W4MNybpjcJjULKNVXubfR5MJqA
"----------End of Wallet Assets --------------"
-------------------------------------------------------------------------
```
### 限价挂单
- **挂限价买单**  低于或者等于市场价的单.
- **挂限价卖单**  高于或者是等于市场价的单.

OceanOne支持三种基类价格: USDT, XIN, BTC, 即: Benz/USDT, Benz/XIN, Benz/BTC, 这儿示范Benz/USDT.

### 限价挂卖单.
新币挂单后,需要等一分钟左右，等OceanOne来初始化新币的相关数据.

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

### 限价挂买单.
新币挂单后,需要等一分钟左右，等OceanOne来初始化新币的相关数据.

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
### 读取币的价格列表
读取币的价格列表，来确认挂单是否成功!

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
### ERC20相关的操作指令

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

[完整的代码](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)
