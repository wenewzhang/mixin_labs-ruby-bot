require 'openssl'
require '../mixin_bot/lib/mixin_bot'
require 'yaml'

yaml_hash = YAML.load_file('./config.yml')

MixinBot.client_id  = yaml_hash["MIXIN_CLIENT_ID"]
MixinBot.session_id = yaml_hash["MIXIN_SESSION_ID"]
MixinBot.client_secret = yaml_hash["MIXIN_CLIENT_SECRET"]
MixinBot.pin_token   = yaml_hash["MIXIN_PIN_TOKEN"]
MixinBot.private_key = yaml_hash["MIXIN_PRIVATE_KEY"]

access_token = MixinBot.api.access_token("GET","/","")

rsa_key = OpenSSL::PKey::RSA.new(1024)
private_key = rsa_key.to_pem()
public_key = rsa_key.public_key.to_pem
secret_client = public_key.sub("-----BEGIN PUBLIC KEY-----\n","").sub("\n-----END PUBLIC KEY-----\n","")
reqInfo = MixinBot.api.create_user("ruby bot",secret_client)
p reqInfo
