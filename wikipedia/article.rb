require 'rest-client'
module Article
  def find_article lat, long
    endpoint_geo = "https://en.wikipedia.org/w/api.php?action=query&format=json&list=geosearch&gsradius=10000&gscoord="
    endpoint_article = "http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&titles="
    response = JSON.parse RestClient::Request.execute(:url => URI.encode(endpoint_geo + "#{lat}|#{long}"), :method => :get, :verify_ssl => false)
    size = response['query']['geosearch'].size
    title = response['query']['geosearch'][rand size]['title']
    response = JSON.parse RestClient::Request.execute(:url => URI.encode(endpoint_article + "#{title}"), :method => :get, :verify_ssl => false)
    hash_keys = response['query']['pages'].keys
    result = response['query']['pages'][hash_keys[0]]['extract']
    index = result.index '</p>'
    result.slice 0, index
  end
  module_function :find_article
end
