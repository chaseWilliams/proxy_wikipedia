require './wikipedia/loader'

class App < Sinatra::Base
  # Remember that this is a helper function that will process each request (regardless of endpoint) before
  # processing the get/post/put sections below
  before do
    content_type 'application/json'
    # [...other code will go here, if needed...]
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
