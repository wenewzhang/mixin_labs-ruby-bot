# 通过 Ruby 买卖Bitcoin
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)
上一章介绍了[Exincore](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README4-zhchs.md)，你可以1秒完成资产的市价买卖。如果你想限定价格买卖，或者买卖一些exincore不支持的资产，你需要OceanOne。

## 方案二: 挂单Ocean.One交易所

[Ocean.one](https://github.com/mixinNetwork/ocean.one)是基于Mixin Network的去中心化交易所，它性能一流。
你可以在OceanOne上交易任何资产，只需要将你的币转给OceanOne, 将交易信息写在交易的memo里，OceanOne会在市场里列出你的交易需求，
交易成功后，会将目标币转入到你的MixinNetwork帐上，它有三大特点与优势：
- 不需要在OceanOne注册
- 不需要存币到交易所
- 支持所有Mixin Network上能够转账的资产，所有的ERC20 EOS代币。

### 预备知识:
你先需要创建一个机器人, 方法在 [教程一](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README-zhchs.md).

#### 安装依赖包
我们需要依赖 **msgpack** and **mixin-bot** ,[第四章](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README4-zhchs.md) 已经做过介绍, 你应该先安装过它了.


#### 充币到 Mixin Network, 并读出它的余额.
此处演示用 USDT购买BTC 或者 用BTC购买USDT。交易前，先检查一下钱包地址。
完整的步骤如下:
- 检查比特币或USDT的余额，钱包地址。并记下钱包地址。
- 从第三方交易所或者你的冷钱包中，将币充到上述钱包地址。
- 再检查一下币的余额，看到帐与否。(比特币的到帐时间是5个区块的高度，约100分钟)。

比特币与USDT的充值地址是一样的。

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

#### 取得Ocean.one的市场价格信息
如何来查询Ocean.one市场的价格信息呢？你要先了解你交易的基础币是什么，如果你想买比特币，卖出USDT,那么基础货币就是USDT;如果你想买USDT,卖出比特币，那么基础货币就是比特币.

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

#### 交易前，创建一个Memo!
在第二章里,[Ruby比特币开发教程: 机器人接受比特币并立即退还用户](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2-zhchs.md), 我们学习过转帐，这儿我们介绍如何告诉Ocean.one，我们给它转帐的目的是什么，信息全部放在memo里.
- **side** 方向,"B" 或者 "A", "B"是购买, "A"是出售.
- **targetAsset** 目标虚拟资产的UUID.
- **price** 价格，如果操作方向是"B", 价格就是AssetUUID的价格; 如果操作方向是"B", 价格就是转给Ocean.one币的价格.

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

买入BTC的代码如下：

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

#### 出售BTC的例子
转打算出售的XIN给Ocean.one(OCEANONE_BOT),将你打算换回来的目标虚拟资产的UUID放入memo.

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

一个成功的挂单如下：

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

#### 取消挂单
Ocean.one将trace_id当做订单，比如上面的例子， **89025aab-598f-43e5-834a-2feaa01797ff** 就是订单号，我们用他来取消订单。

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

#### 通过读取资产余额，来确认到帐情况
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

## 源代码执行
编译执行，即可开始交易了.

## 源代码执行
编译执行，即可开始交易了.

- [x] **ruby bitcoin-wallet-ruby.rb**  运行.

本代码执行时的命令列表:

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

[完整代码](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)
