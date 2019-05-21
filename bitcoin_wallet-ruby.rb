require 'openssl'
require '../mixin_bot/lib/mixin_bot'
require 'yaml'
require 'csv'

loop do

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
  puts PromptMsg
  cmd = gets.chomp
  if cmd == "1"
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


    CSV.open("mybitcoin_wallet.csv", "w") do |csv|
      csv << [private_key, reqInfo["data"]["pin_token"], reqInfo["data"]["session_id"], reqInfo["data"]["user_id"]]
    end

    MixinBot.api.clear
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
  if cmd == "q"
    break
  end
end
