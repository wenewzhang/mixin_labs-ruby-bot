require 'http'
module Utils
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
     # .each { |x|
     #       puts x["exchange_asset_symbol"] +  "/" +  x["base_asset_symbol"] + " " +
     #            x["price"] + " " + x["minimum_amount"] + " " + x["maximum_amount"] +
     #            " " + x["exchanges"][0]
     #     }
  end
end
