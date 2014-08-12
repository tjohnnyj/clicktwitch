class Search < ActiveRecord::Base    
  SEARCH_API_URL = "https://api.twitter.com/1.1/search/tweets.json"
  TW_CON_KEY = "SktO7It8OIBRlUzkUmLUJdmxM"
  TW_CON_SCRT = "lT8Plk7ezlwUzyXP1EC03YyqKpGIEbyKW9p11Uvim8TifO8hOp"
  OAUTH_URL = "https://api.twitter.com/oauth2/token"
   
  def run_search(query)
    token = request_oauth_token
    conn = Faraday.new SEARCH_API_URL do |c|
      c.request :oauth2, token
      c.response :json, :content_type => /\bjson$/

      c.use :instrumentation
      c.adapter :net_http 
    end
    logger.info(conn)
    
    response = conn.get do |req|
      req.url '/1.1/search/tweets.json'
      req.params = { 'q' => query, 'result_type' => 'mixed', 'count' => 5 }
      logger.info(req)
    end 
    logger.info(response.body) 
  end
  
  def encode_oauth_info 
    combined_string = "#{TW_CON_KEY}:#{TW_CON_SCRT}"
    final_cred = Base64.strict_encode64(combined_string)
    return final_cred  
    logger.info(final_cred) 
  end                                         
  
  def request_oauth_token 
    logger = Logger.new(STDOUT) 
    bearer_token = "#{TW_CON_KEY}:#{TW_CON_SCRT}"
    encoded_bearer_token = Base64.strict_encode64(bearer_token)
    
    conn = Faraday.new(:url => "https://api.twitter.com")
    conn.adapter :net_http
    conn.response :json, :content_type => /\bjson$/
    
    response = conn.post do |req|
      req.url '/oauth2/token'
      req.headers["Authorization"] = "Basic #{encoded_bearer_token}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
      req.params = {'grant_type'=>'client_credentials'}
    end 
    logger.info(response.body)
    access_token = response.body["access_token"]
    return access_token
  end

end
