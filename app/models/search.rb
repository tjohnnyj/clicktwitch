class Search < ActiveRecord::Base    
  SEARCH_API_URL = "https://api.twitter.com/1.1/search/tweets.json"
  TW_CON_KEY = "SktO7It8OIBRlUzkUmLUJdmxM"
  TW_CON_SCRT = "lT8Plk7ezlwUzyXP1EC03YyqKpGIEbyKW9p11Uvim8TifO8hOp"
  OAUTH_URL = "https://api.twitter.com/oauth2/token:443"
   
  
  def run_search
#     parser = HTTParty::Parser.new(response, :json)  
    results = HTTParty.post(SEARCH_API_URL, 
    :body => @message_hash.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
  end
  
  def encode_oauth_info 
    combined_string = "#{TW_CON_KEY}:#{TW_CON_SCRT}"
    final_cred = Base64.strict_encode64(combined_string)
    return final_cred  
    logger.info(final_cred) 
  end                                         
  
  def request_oauth_token 
    bearer_token = "#{TW_CON_KEY}:#{TW_CON_SCRT}"
    encoded_bearer_token = Base64.strict_encode64(bearer_token)

    url = URI.parse("https://api.twitter.com/oauth2/token")

    https = Net::HTTP.new(url.host, 443)
    https.use_ssl = true

    https.start do
      header = {}
      header["Authorization"] = "Basic #{encoded_bearer_token}"
      header["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"

      req = Net::HTTP::Post.new(url.path, header)
      req.body = "grant_type=client_credentials"

      resp = https.request(req)
      puts resp.body
      logger.info(resp.body)
    end     
  end

end
