require './wikipedia/loader'

class App < Sinatra::Base
  before do
    content_type 'application/json'

  end

  get '/standard' do
    extract = Article.find_article params[:latitude], params[:longitude]
    {status: 'ok', extract: extract}.to_json
  end

  get '/zip_code' do
    zip_code = params[:zip_code]
    if zip_code.class == Fixnum then zip_code.to_s end
    latitude = zip_code.to_lat
    longitude = zip_code.to_lon
    extract = Article.find_article latitude, longitude
    {status: 'ok', extract: extract}.to_json
  end
end
