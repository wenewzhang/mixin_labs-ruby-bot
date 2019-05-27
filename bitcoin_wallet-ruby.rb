require 'openssl'
require '../mixin_bot/lib/mixin_bot'
require 'yaml'
require 'csv'
require './utils'
require 'msgpack'
require 'base64'
require 'uuid'
require 'cgi'

WALLET_NAME      = "./mybitcoin_wallet.csv"
DEFAULT_PIN      = "123456"
EXIN_BOT         = "61103d28-3ac2-44a2-ae34-bd956070dab1"
OCEANONE_BOT     = "aaff5bef-42fb-4c9f-90e0-29f69176b7d4"
BTC_ASSET_ID     = "c6d0c728-2624-429b-8e0d-d9d19b6592fa"

EOS_ASSET_ID     = "6cfe566e-4aad-470b-8c9a-2fd35b49c68d"
USDT_ASSET_ID    = "815b0b1a-2764-3736-8faa-42d694fa620a"
# private static final String ETC_ASSET_ID     = "2204c1ee-0ea2-4add-bb9a-b3719cfff93a";
# private static final String XRP_ASSET_ID     = "23dfb5a5-5d7b-48b6-905f-3970e3176e27";
# private static final String XEM_ASSET_ID     = "27921032-f73e-434e-955f-43d55672ee31";
ETH_ASSET_ID     = "43d61dcd-e413-450d-80b8-101d5e903357"
# private static final String DASH_ASSET_ID    = "6472e7e3-75fd-48b6-b1dc-28d294ee1476";
# private static final String DOGE_ASSET_ID    = "6770a1e5-6086-44d5-b60f-545f9d9e8ffd";
# private static final String LTC_ASSET_ID     = "76c802a2-7c88-447f-a93e-c29c9e5dd9c8";
# private static final String SIA_ASSET_ID     = "990c4c29-57e9-48f6-9819-7d986ea44985";
# private static final String ZEN_ASSET_ID     = "a2c5d22b-62a2-4c13-b3f0-013290dbac60";
# private static final String ZEC_ASSET_ID     = "c996abc9-d94e-4494-b1cf-2a3fd3ac5714";
# private static final String BCH_ASSET_ID     = "fd11b6e3-0b87-41f1-a41f-f0e9b49e5bf0";
XIN_ASSET_ID     = "c94ac88f-4671-3976-b60a-09064f1811e8"
CNB_ASSET_ID     = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
# private static final String ERC20_BENZ       = "2b9c216c-ef60-398d-a42a-eba1b298581d";
BTC_WALLET_ADDR  = "14T129GTbXXPGXXvZzVaNLRFPeHXD1C25C"
MASTER_UUID      = "0b4f49dc-8fb4-4539-9a89-fb3afc613747"
# private static final String WALLET_FILANAME  = "./mybitcoin_wallet.csv";
EOS_THIRD_EXCHANGE_NAME = "huobideposit"
EOS_THIRD_EXCHANGE_TAG  = "1872050"

PromptMsg  = "1: Create Bitcoin Wallet and update PIN\n2: Read Bitcoin balance & address \n3: Read USDT balance & address\n4: Read EOS balance & address\n" +
             "tbb:Transfer BTC from Bot to Wallet\ntbm:Transfer BTC from Wallet to Master\n" +
             "teb:Transfer EOS from Bot to Wallet\ntem:Transfer EOS from Wallet to Master\n" +
             "tub:Transfer USDT from Bot to Wallet\ntum:Transfer USDT from Wallet to Master\n" +
             "tcb:Transfer CNB from Bot to Wallet\ntcm:Transfer CNB from Wallet to Master\n" +
             "txb:Transfer XIN from Bot to Wallet\ntxm:Transfer XIN from Wallet to Master\n" +
             "tbb:Transfer ETH from Bot to Wallet\nttm:Transfer ETH from Wallet to Master\n" +
             "trb:Transfer ERC20 from Bot to Wallet\ntrm:Transfer ERC20 from Wallet to Master\n" +
             "5: Pay All BTC to ExinCore exchange USDT\n6: Pay All USDT to ExinCore buy BTC\n" +
             "10: Pay all XIN to ExinCore exchange USDT\n" +
             "11: Pay all ETH to ExinCore exchange USDT\n" +
             "12: Pay all EOS to ExinCore exchange USDT\n" +
             "7: Read Snapshots\n8: Fetch market price(USDT)\n9: Fetch market price(BTC)\n" +
             "v: Verify Wallet Pin\nwb: Withdraw BTC\nwe: WitchDraw EOS\nab: Read Bot Assets\naw: Read Wallet Assets\n" +
             "o: OceanOne Exchange\n" +
             "q: Exit \nMake your choose(eg: q for Exit!): "

yaml_hash = YAML.load_file('./config.yml')
bot_config = {
               client_id: yaml_hash["MIXIN_CLIENT_ID"],
               session_id: yaml_hash["MIXIN_SESSION_ID"],
               client_secret: yaml_hash["MIXIN_CLIENT_SECRET"],
               pin_token:    yaml_hash["MIXIN_PIN_TOKEN"],
               private_key: yaml_hash["MIXIN_PRIVATE_KEY"]
               }
botAccount = MixinBot.new(bot_config)

if File.file?(WALLET_NAME)
  table = CSV.read(WALLET_NAME)
  wallet_config = {
                 client_id: table[0][3],
                 session_id: table[0][2],
                 client_secret: '',
                 pin_token:    table[0][1],
                 private_key: table[0][0]
                 }
  walletAccount = MixinBot.new(wallet_config)
  wallet_userid = table[0][3]
end

loop do
  puts "-------------------------------------------------------------------------"
  puts PromptMsg
  cmd = gets.chomp
  if cmd == "1"
    if File.file?(WALLET_NAME)
      p "mybitcoin_wallet.csv has already existed !"
      next
    end

    rsa_key = OpenSSL::PKey::RSA.new(1024)
    private_key = rsa_key.to_pem()
    p private_key
    public_key = rsa_key.public_key.to_pem
    secret_client = public_key.sub("-----BEGIN PUBLIC KEY-----\n","").sub("\n-----END PUBLIC KEY-----\n","")
    reqInfo = botAccount.create_user("ruby bot",secret_client)
    p reqInfo["data"]["pin_token"]
    p reqInfo["data"]["user_id"]
    p reqInfo["data"]["session_id"]


    CSV.open(WALLET_NAME, "wb") do |csv|
      csv << [private_key, reqInfo["data"]["pin_token"], reqInfo["data"]["session_id"], reqInfo["data"]["user_id"]]
    end
    if File.file?(WALLET_NAME)
      table = CSV.read(WALLET_NAME)
      wallet_config = {
                     client_id: table[0][3],
                     session_id: table[0][2],
                     client_secret: '',
                     pin_token:    table[0][1],
                     private_key: table[0][0]
                     }
      walletAccount = MixinBot.new(wallet_config)
      wallet_userid = table[0][3]
      pinInfo = walletAccount.update_pin('',DEFAULT_PIN)
      p pinInfo
    end
  end
  if cmd == "aw"
    assetsInfo = walletAccount.read_assets()
    p "--------The Wallet Assets List-----------------"
    assetsInfo["data"].each { |x| puts x["symbol"] + " " +
                                x["balance"] + " " + x["public_key"] +
                                x["account_name"] + " " + x["account_tag"]}
    p "----------End of Wallet Assets --------------"
  end
  if cmd == "ab"
    assetsInfo = botAccount.read_assets()
    p "--------The Bot Assets List-----------------"
    assetsInfo["data"].each { |x| puts x["symbol"] + " " +
                                x["balance"] + " " + x["public_key"] +
                                x["account_name"] + " " + x["account_tag"]}
    p "----------End of Bot Assets --------------"
    # pinInfo = MixinBot.api.update_pin('',DEFAULT_PIN)
    # p pinInfo
  end
  if cmd == "2"
    assetsInfo = walletAccount.read_asset(BTC_ASSET_ID)
    p "The BTC wallet address is " + assetsInfo["data"]["public_key"]
    p "The BTC wallet balance is " + assetsInfo["data"]["balance"]
  end
  if cmd == "3"
    assetsInfo = walletAccount.read_asset(BTC_ASSET_ID)
    p "The EOS wallet address is " + assetsInfo["data"]["account_name"] + " " + assetsInfo["data"]["account_tag"]
    p "The EOS wallet balance is " + assetsInfo["data"]["balance"]
  end
  if cmd == "wb"
    addressInfo = walletAccount.create_withdraw_address(BTC_ASSET_ID,
                                                         DEFAULT_PIN,
                                                         BTC_WALLET_ADDR,
                                                         "","",
                                                         "from ruby")
    p addressInfo
    p "The address id is " + addressInfo["data"]["address_id"] + " it is needed by read fee!"
    # addressInfo2 = MixinBot.api.del_withdraw_address(addressInfo["data"]["address_id"], DEFAULT_PIN)
    # p addressInfo2

    withdrawInfo = walletAccount.withdrawals(addressInfo["data"]["address_id"],
                                            DEFAULT_PIN,
                                            "0.1",
                                            SecureRandom.uuid,"from ruby")
    p withdrawInfo
  end
  if cmd == "we"
    addressInfo = walletAccount.create_withdraw_address(EOS_ASSET_ID,
                                                         DEFAULT_PIN,
                                                         "",
                                                         EOS_THIRD_EXCHANGE_NAME,
                                                         EOS_THIRD_EXCHANGE_TAG,
                                                         "from ruby")
    p addressInfo
    p "The address id is " + addressInfo["data"]["address_id"] + " it is needed by read fee!"
    # addressInfo2 = MixinBot.api.del_withdraw_address(addressInfo["data"]["address_id"], DEFAULT_PIN)
    # p addressInfo2
    withdrawInfo = walletAccount.withdrawals(addressInfo["data"]["address_id"],
                                            DEFAULT_PIN,
                                            "0.1",
                                            SecureRandom.uuid,"from ruby")
    p withdrawInfo
  end
  if cmd == "teb"
    botAssetsInfo = botAccount.read_asset(EOS_ASSET_ID)
    if botAssetsInfo["data"]["balance"].to_f > 0
      transInfo = botAccount.create_transfer(botAccount.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
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
  if cmd == "tcb"
    botAssetsInfo = botAccount.read_asset(CNB_ASSET_ID)
    if botAssetsInfo["data"]["balance"].to_f > 0
      transInfo = botAccount.create_transfer(botAccount.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                        {
                                          asset_id: CNB_ASSET_ID,
                                          opponent_id: wallet_userid,
                                          amount: botAssetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "tcm"
    assetsInfo = walletAccount.read_asset(CNB_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: CNB_ASSET_ID,
                                          opponent_id: MASTER_UUID,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "txb"
    botAssetsInfo = botAccount.read_asset(XIN_ASSET_ID)
    if botAssetsInfo["data"]["balance"].to_f > 0
      transInfo = botAccount.create_transfer(botAccount.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                        {
                                          asset_id: XIN_ASSET_ID,
                                          opponent_id: wallet_userid,
                                          amount: botAssetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "txm"
    assetsInfo = walletAccount.read_asset(XIN_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: XIN_ASSET_ID,
                                          opponent_id: MASTER_UUID,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "ttb"
    botAssetsInfo = botAccount.read_asset(ETH_ASSET_ID)
    if botAssetsInfo["data"]["balance"].to_f > 0
      transInfo = botAccount.create_transfer(botAccount.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                        {
                                          asset_id: ETH_ASSET_ID,
                                          opponent_id: wallet_userid,
                                          amount: botAssetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "ttm"
    assetsInfo = walletAccount.read_asset(ETH_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: ETH_ASSET_ID,
                                          opponent_id: MASTER_UUID,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "tub"
    botAssetsInfo = botAccount.read_asset(USDT_ASSET_ID)
    if botAssetsInfo["data"]["balance"].to_f > 0
      transInfo = botAccount.create_transfer(botAccount.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                        {
                                          asset_id: USDT_ASSET_ID,
                                          opponent_id: wallet_userid,
                                          amount: botAssetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "tum"
    assetsInfo = walletAccount.read_asset(USDT_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: USDT_ASSET_ID,
                                          opponent_id: MASTER_UUID,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
    end
  end
  if cmd == "tbb"
    botAssetsInfo = botAccount.read_asset(BTC_ASSET_ID)
    if botAssetsInfo["data"]["balance"].to_f > 0
      transInfo = botAccount.create_transfer(botAccount.encrypt_pin(yaml_hash["MIXIN_PIN_CODE"]),
                                        {
                                          asset_id: BTC_ASSET_ID,
                                          opponent_id: wallet_userid,
                                          amount: botAssetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "tbm"
    assetsInfo = walletAccount.read_asset(BTC_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: BTC_ASSET_ID,
                                          opponent_id: MASTER_UUID,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: "from ruby"
                                        })
      p transInfo
   end
  end
  if cmd == "8"
    Utils.ExinCoreMarketPriceRequest(USDT_ASSET_ID)
  end
  if cmd == "9"
    Utils.ExinCoreMarketPriceRequest(BTC_ASSET_ID)
  end
  if cmd == "5"
    memo1 = Base64.encode64(MessagePack.pack({
    'A' => UUID.parse(USDT_ASSET_ID).to_raw
    }))
    memo = memo1.sub("\n","")
    p memo
    assetsInfo = walletAccount.read_asset(BTC_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: BTC_ASSET_ID,
                                          opponent_id: EXIN_BOT,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: memo
                                        })
       p transInfo
    end
  end
  if cmd == "10"
    memo1 = Base64.encode64(MessagePack.pack({
    'A' => UUID.parse(USDT_ASSET_ID).to_raw
    }))
    memo = memo1.sub("\n","")
    p memo
    assetsInfo = walletAccount.read_asset(XIN_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: XIN_ASSET_ID,
                                          opponent_id: EXIN_BOT,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: memo
                                        })
       p transInfo
    end
  end
  if cmd == "11"
    memo1 = Base64.encode64(MessagePack.pack({
    'A' => UUID.parse(USDT_ASSET_ID).to_raw
    }))
    memo = memo1.sub("\n","")
    p memo
    assetsInfo = walletAccount.read_asset(ETH_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: ETH_ASSET_ID,
                                          opponent_id: EXIN_BOT,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: memo
                                        })
       p transInfo
    end
  end
  if cmd == "12"
    memo1 = Base64.encode64(MessagePack.pack({
    'A' => UUID.parse(USDT_ASSET_ID).to_raw
    }))
    memo = memo1.sub("\n","")
    p memo
    assetsInfo = walletAccount.read_asset(EOS_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: EOS_ASSET_ID,
                                          opponent_id: EXIN_BOT,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: memo
                                        })
       p transInfo
    end
  end
  if cmd == "6"
    memo1 = Base64.encode64(MessagePack.pack({
    'A' => UUID.parse(BTC_ASSET_ID).to_raw
    }))
    memo = memo1.sub("\n","")
    p memo
    assetsInfo = walletAccount.read_asset(USDT_ASSET_ID)
    if assetsInfo["data"]["balance"].to_f > 0
      transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                        {
                                          asset_id: USDT_ASSET_ID,
                                          opponent_id: EXIN_BOT,
                                          amount: assetsInfo["data"]["balance"],
                                          trace_id: SecureRandom.uuid,
                                          memo: memo
                                        })
       p transInfo
   end
  end
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
  if cmd == "o"
    loop do
      oMsg = "1: Fetch BTC/USDT Order Book\n2: Fetch XIN/USDT Order Book\n" +
             "3: Fetch ERC20/USDT Order Book\n" +
             "s1: Sell BTC/USDT\n" + "b1: Buy BTC/USDT\n" +
             "s2: Sell XIN/USDT\n" + "b2: Buy XIN/USDT\n" +
             "s3: Sell ERC20/USDT\n" + "s3: Buy ERC20/USDT\n" +
             "c: Cancel the order\n" +
             "q: Exit \nMake your choose(eg: q for Exit!): "
      puts oMsg
      ocmd = gets.chomp
      if ocmd ==  "q"
        break
      end
      if ocmd == "1"
        Utils.OceanOneMarketPriceRequest(BTC_ASSET_ID, USDT_ASSET_ID)
      end
      if ocmd == "2"
        Utils.OceanOneMarketPriceRequest(XIN_ASSET_ID, USDT_ASSET_ID)
      end
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
      if ocmd == "s2"
        p "Input the price of XIN/USDT: "
        bprice = gets.chomp
        p "Input the amount of XIN: "
        amount = gets.chomp
        memo = Utils.GenerateOceanMemo(USDT_ASSET_ID,"A",bprice)
        p memo
        assetsInfo = walletAccount.read_asset(XIN_ASSET_ID)
        if assetsInfo["data"]["balance"].to_f > 0 && assetsInfo["data"]["balance"].to_f >= amount.to_f
          transInfo = walletAccount.create_transfer(walletAccount.encrypt_pin(DEFAULT_PIN),
                                            {
                                              asset_id: XIN_ASSET_ID,
                                              opponent_id: OCEANONE_BOT,
                                              amount: amount,
                                              trace_id: SecureRandom.uuid,
                                              memo: memo
                                            })
          p transInfo
          p "The Order id is " + transInfo["data"]["trace_id"] + " It's needed by cancel-order!"
        else
          p "Not enough XIN"
        end
      end
      if ocmd == "b2"
        p "Input the price of XIN/USDT: "
        bprice = gets.chomp
        p "Input the amount of USDT: "
        amount = gets.chomp
        memo = Utils.GenerateOceanMemo(XIN_ASSET_ID,"B",bprice)
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
    end
  end
  if cmd == "q"
    break
  end
end
