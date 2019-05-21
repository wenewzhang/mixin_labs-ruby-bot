require 'openssl'
require '../mixin_bot/lib/mixin_bot'
require 'yaml'
require 'csv'

WALLET_NAME      = "./mybitcoin_wallet.csv"
DEFAULT_PIN      = "123456"
EXIN_BOT         = "61103d28-3ac2-44a2-ae34-bd956070dab1"
OCEANONE_BOT     = "aaff5bef-42fb-4c9f-90e0-29f69176b7d4"
BTC_ASSET_ID     = "c6d0c728-2624-429b-8e0d-d9d19b6592fa"

EOS_ASSET_ID     = "6cfe566e-4aad-470b-8c9a-2fd35b49c68d"
# private static final String USDT_ASSET_ID    = "815b0b1a-2764-3736-8faa-42d694fa620a";
# private static final String ETC_ASSET_ID     = "2204c1ee-0ea2-4add-bb9a-b3719cfff93a";
# private static final String XRP_ASSET_ID     = "23dfb5a5-5d7b-48b6-905f-3970e3176e27";
# private static final String XEM_ASSET_ID     = "27921032-f73e-434e-955f-43d55672ee31";
# private static final String ETH_ASSET_ID     = "43d61dcd-e413-450d-80b8-101d5e903357";
# private static final String DASH_ASSET_ID    = "6472e7e3-75fd-48b6-b1dc-28d294ee1476";
# private static final String DOGE_ASSET_ID    = "6770a1e5-6086-44d5-b60f-545f9d9e8ffd";
# private static final String LTC_ASSET_ID     = "76c802a2-7c88-447f-a93e-c29c9e5dd9c8";
# private static final String SIA_ASSET_ID     = "990c4c29-57e9-48f6-9819-7d986ea44985";
# private static final String ZEN_ASSET_ID     = "a2c5d22b-62a2-4c13-b3f0-013290dbac60";
# private static final String ZEC_ASSET_ID     = "c996abc9-d94e-4494-b1cf-2a3fd3ac5714";
# private static final String BCH_ASSET_ID     = "fd11b6e3-0b87-41f1-a41f-f0e9b49e5bf0";
# private static final String XIN_ASSET_ID     = "c94ac88f-4671-3976-b60a-09064f1811e8";
# private static final String CNB_ASSET_ID     = "965e5c6e-434c-3fa9-b780-c50f43cd955c";
# private static final String ERC20_BENZ       = "2b9c216c-ef60-398d-a42a-eba1b298581d";
BTC_WALLET_ADDR  = "14T129GTbXXPGXXvZzVaNLRFPeHXD1C25C"
# private static final String MASTER_UUID      = "0b4f49dc-8fb4-4539-9a89-fb3afc613747";
# private static final String WALLET_FILANAME  = "./mybitcoin_wallet.csv";
EOS_THIRD_EXCHANGE_NAME = "huobideposit"
EOS_THIRD_EXCHANGE_TAG  = "1872050"

PromptMsg  = "1: Create Bitcoin Wallet and update PIN\n2: Read Bitcoin balance & address \n3: Read USDT balance & address\n4: Read EOS balance & address\n" +
             "tbb:Transfer BTC from Bot to Wallet\ntbm:Transfer BTC from Wallet to Master\n" +
             "teb:Transfer EOS from Bot to Wallet\ntem:Transfer EOS from Wallet to Master\n" +
             "tub:Transfer USDT from Bot to Wallet\ntum:Transfer USDT from Wallet to Master\n" +
             "tcb:Transfer CNB from Bot to Wallet\ntcm:Transfer CNB from Wallet to Master\n" +
             "txb:Transfer XIN from Bot to Wallet\ntxm:Transfer XIN from Wallet to Master\n" +
             "trb:Transfer ERC20 from Bot to Wallet\ntrm:Transfer ERC20 from Wallet to Master\n" +
             "5: Pay 0.0001 BTC to ExinCore buy USDT\n6: Pay $1 USDT to ExinCore buy BTC\n7: Read Snapshots\n8: Fetch market price(USDT)\n9: Fetch market price(BTC)\n" +
             "v: Verify Wallet Pin\nwb: Withdraw BTC\nwe: WitchDraw EOS\nab: Read Bot Assets\naw: Read Wallet Assets\n" +
             "o: Ocean.One Exchange\nq: Exit \nMake your choose(eg: q for Exit!): "

loop do
  puts "-------------------------------------------------------------------------"
  puts PromptMsg
  cmd = gets.chomp
  if cmd == "1"
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

    botAssetsInfo = MixinBot.api.read_assets()
    p botAssetsInfo

    MixinBot.client_id  = reqInfo["data"]["user_id"]
    MixinBot.session_id = reqInfo["data"]["session_id"]
    MixinBot.client_secret = ""
    MixinBot.pin_token   = reqInfo["data"]["pin_token"]
    MixinBot.private_key = private_key
    p "--------------------------------"
    botAssetsInfo2 = MixinBot.api.read_assets()
    p botAssetsInfo2
  end
  if cmd == "aw"
    table = CSV.read(WALLET_NAME)
    puts table[0][1]
    MixinBot.client_id = table[0][3]
    MixinBot.session_id = table[0][2]
    MixinBot.pin_token = table[0][1]
    MixinBot.private_key = table[0][0]
    botAssetsInfo = MixinBot.api.read_assets()
    p botAssetsInfo
    # pinInfo = MixinBot.api.update_pin('',"123456")
    # p pinInfo
  end
  if cmd == "2"
    table = CSV.read(WALLET_NAME)
    MixinBot.client_id = table[0][3]
    MixinBot.session_id = table[0][2]
    MixinBot.pin_token = table[0][1]
    MixinBot.private_key = table[0][0]
    botAssetsInfo = MixinBot.api.read_asset(BTC_ASSET_ID)
    p botAssetsInfo
  end
  if cmd == "3"
    table = CSV.read(WALLET_NAME)
    MixinBot.client_id = table[0][3]
    MixinBot.session_id = table[0][2]
    MixinBot.pin_token = table[0][1]
    MixinBot.private_key = table[0][0]
    botAssetsInfo = MixinBot.api.read_asset(EOS_ASSET_ID)
    p botAssetsInfo
  end
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
    addressInfo2 = MixinBot.api.get_withdraw_address(addressInfo["data"]["address_id"])
    p addressInfo2
  end
  if cmd == "q"
    break
  end
end
