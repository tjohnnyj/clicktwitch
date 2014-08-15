class Search < ActiveRecord::Base    
  SEARCH_API_URL = "https://api.twitter.com/1.1/search/tweets.json"
  TW_CON_KEY = "SktO7It8OIBRlUzkUmLUJdmxM"
  TW_CON_SCRT = "lT8Plk7ezlwUzyXP1EC03YyqKpGIEbyKW9p11Uvim8TifO8hOp"
  OAUTH_URL = "https://api.twitter.com/oauth2/token"
   
  def run_search(query, current_user_id)
    token = token_for_user(current_user_id)
    conn = Faraday.new SEARCH_API_URL do |c|
      c.response :json, :content_type => /\bjson$/

      c.use :instrumentation
      c.adapter :net_http 
    end
    logger.info(conn)
    string = build_signature_request(query, current_user_id)  
    response = conn.post do |req|
      req.headers["Authorization"] = string
      req.url '/1.1/search/tweets.json'
      req.params = { 'q' => query, 'result_type' => 'mixed', 'count' => 5 }
      logger.info(req)
    end 
    logger.info(response.body) 
  end
  
  def build_signature_request(query, current_user_id)
    q = encode_query(query)
    url = encoded_url
    nonce = get_oauth_nonce
    options = get_options 
    time = Time.now.to_i    
    token = token_for_user(current_user_id)
    signature = "#{url}&include_entities=true&oauth_consumer_key=#{TW_CON_KEY}&oauth_nonce=#{nonce}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{time}&oauth_token=#{token}&oauth_version=1.0&&#{q}&#{options}"
    signature = OAuth::Helper.escape(signature) 
    signed = "OAUTH #{signature}"
    return signed
  end
  
  def encoded_url
    string = "GET #{SEARCH_API_URL}"
    encoded_string = OAuth::Helper.escape(string)
    return encoded_string
  end
  
  def encode_query(query)
    q = OAuth::Helper.escape(query)
    return q
  end 
  
  def get_oauth_nonce
    nonce = SecureRandom.hex(32)
    return nonce
  end
  
  def get_options
    result_type = "mixed"
    count = 10
    search_options = "#{result_type}&#{count}"
    encoded_options = OAuth::Helper.escape(search_options)
    return  encoded_options
  end
  
  def token_for_user(current_user_id)
    @user = User.find(current_user_id)    
    token = @user.confirmation_token
    return token
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
