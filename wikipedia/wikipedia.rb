
module Article
  class Proxy
    def initialize
      @redis = Redis.new(url: ENV['REDIS_URI'])
      @logger_out = Logger.new(STDOUT)
    end
    def find_article lat, lon
      geo = "#{lat}|#{lon}"
      data = find_article_helper lat, lon
      unless @redis.exists(geo)
        @logger_out.info "The key #{geo} wasn't found, so setting new article extracts"
        unless data['status'] == 'ok'
          @logger_out.warn "Woah- looks like the key #{geo} has a fail status. Watch out!"
        else
          @logger_out.info "The key #{geo} was successfully set with this information: \nTitle: #{data[:title]}\n\n
                           #{data[:extract]}\n\n"
        end
      else
        @logger_out.info "The key #{geo} was found, overriding..."
      end
      @redis.set geo, data.to_json
      result = JSON.parse @redis.get geo
      @logger_out.info "Key #{geo} successfully captured!"
      result
    end

    def find_article_helper lat, lon
      endpoint_base = 'https://en.wikipedia.org/w/api.php?action=query&'
      endpoint_geo = 'format=json&list=geosearch&gsradius=10000&gslimit=100&gscoord='
      endpoint_article = 'prop=extracts&format=json&titles='
      begin
        response = JSON.parse RestClient::Request.execute(:url => URI.encode(
            endpoint_base + endpoint_geo + "#{lat}|#{lon}"), :method => :get, :verify_ssl => false)
        size = response['query']['geosearch'].size
        title = response['query']['geosearch'][rand size]['title']
        response = JSON.parse RestClient::Request.execute(:url => URI.encode(
            endpoint_base + endpoint_article + "#{title}"), :method => :get, :verify_ssl => false)
        hash_keys = response['query']['pages'].keys
        result = response['query']['pages'][hash_keys[0]]['extract']
        index = result.index '</p>'
        extract = result.slice 0, index
        to_be_returned = {status: 'ok', title: title, extract: extract.strip}
      rescue StandardError => e
        to_be_returned = {status: 'fail'}
      end
      to_be_returned
    end
  end
end
