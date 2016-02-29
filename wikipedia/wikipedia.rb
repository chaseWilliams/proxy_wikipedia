
module Article
  class Proxy
    def initialize
      @redis = Redis.new(url: ENV['REDIS_URI'])
      @logger_out = Logger.new(STDOUT)
      @logger_err = Logger.new(STDERR)
    end
    def find_article lat, long
      geo = "#{lat}|#{long}"
      unless @redis.exists geo
        @logger_out.info "The key #{geo} wasn't found, so fetching new article extracts"
        data = find_article_helper lat, long
        @redis.set geo, data.to_json
        @logger_out.info "The key #{geo} was successfully set with this information: \nTitle: #{data[:title]}\n\n
#{data[:extract]}\n\n"
      end
      result = JSON.parse @redis.get geo
      @logger_out.info "Key #{geo} successfully captured!"
      result
    end
    def find_article_helper lat, long
      endpoint_base = 'https://en.wikipedia.org/w/api.php?action=query&'
      endpoint_geo = 'format=json&list=geosearch&gsradius=10000&gscoord='
      endpoint_article = 'prop=extracts&format=json&titles='
      response = JSON.parse RestClient::Request.execute(:url => URI.encode(
          endpoint_base + endpoint_geo + "#{lat}|#{long}"), :method => :get, :verify_ssl => false)
      size = response['query']['geosearch'].size
      title = response['query']['geosearch'][rand size]['title']
      response = JSON.parse RestClient::Request.execute(:url => URI.encode(
          endpoint_base + endpoint_article + "#{title}"), :method => :get, :verify_ssl => false)
      hash_keys = response['query']['pages'].keys
      result = response['query']['pages'][hash_keys[0]]['extract']
      index = result.index '</p>'
      extract = result.slice 0, index
      {title: title, extract: extract}
    end
  end
end
