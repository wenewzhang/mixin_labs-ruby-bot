# 如何用 Ruby 买卖Bitcoin
![](https://github.com/wenewzhang/mixin_labs-ruby-bot/raw/master/ruby-btc.jpg)

## 方案一: 通过ExinCore API进行币币交易
[Exincore](https://github.com/exinone/exincore) 提供了基于Mixin Network的币币交易API.

你可以支付USDT给ExinCore, ExinCore会以最低的价格，最优惠的交易费将你购买的比特币转给你, 每一币交易都是匿名的，并且可以在区块链上进行验证，交易的细节只有你与ExinCore知道！

ExinCore 也不知道你是谁，它只知道你的UUID.

### 预备知识:
你先需要创建一个机器人, 方法在 [教程一](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README-zhchs.md).

#### 安装依赖包
正如教程一里我们介绍过的， 我们需要依赖 **mixin-bot**, 你应该先安装过它了， 这儿我们再安装 **easy-uuid, msgpack** 两个软件包.
```bash
 gem install msgpack
 gem install easy-uuid
```
#### 充币到 Mixin Network, 并读出它的余额.
ExinCore可以进行BTC, USDT, EOS, ETH 等等交易， 这儿演示如果用 USDT购买BTC 或者 用BTC购买USDT, 交易前，先检查一下钱包地址！
完整的步骤如下:
- 检查比特币或USDT的余额，钱包地址。并记下钱包地址。
- 从第三方交易所或者你的冷钱包中，将币充到上述钱包地址。
- 再检查一下币的余额，看到帐与否。(比特币的到帐时间是5个区块的高度，约100分钟)。

**请注意，比特币与USDT的地址是一样的。**
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
#### 查询ExinCore市场的价格信息
如果来查询ExinCore市场的价格信息呢？你要先了解你交易的基础币是什么，如果你想买比特币，卖出USDT,那么基础货币就是USDT;如果你想买USDT,卖出比特币，那么基础货币就是比特币.
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

#### 交易前，创建一个Memo!
在第二章里,[基于Mixin Network的Ruby比特币开发教程: 机器人接受比特币并立即退还用户](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/README2-zhchs.md), 我们学习过退还用户比特币，在这里，我们除了给ExinCore支付币外，还要告诉他我们想购买的币是什么，即将想购买的币存到memo里。
```ruby
memo1 = Base64.encode64(MessagePack.pack({
'A' => UUID.parse(USDT_ASSET_ID).to_raw
}))
memo = memo1.sub("\n","")
```

#### 币币交易的完整流程
转币给ExinCore时，将memo写入你希望购买的币, 这个memo别错了，否则，ExinCore需要人工操作来退币！
如果你想卖出比特币买入USDT,调用方式如下：

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

如果你想卖出USDT买入比特币,调用方式如下：

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

交易完成后，Exincore会将你需要的币转到你的帐上，同样，会在memo里，记录成交价格，交易费用等信息！你只需要按下面的方式解开即可！
- **read_snapshots** 读取钱包的交易记录。
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

一次成功的交易如下：
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

#### 读取币的余额
通过读取币的余额，来确认交易情况！
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
执行 **ruby bitcoin_wallet-ruby.rb**  即可开始交易了.

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


[完整代码](https://github.com/wenewzhang/mixin_labs-ruby-bot/blob/master/bitcoin_wallet-ruby.rb)

## Solution Two: List your order on Ocean.One exchange
