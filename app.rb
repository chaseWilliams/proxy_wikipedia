require './wikipedia/loader'

class App < Sinatra::Base
  before do
    content_type 'application/json'
  end

  get '/standard' do
    data = Article.find_article params[:latitude].round(3), params[:longitude].round(3)
    {status: 'ok', title: data[:title], extract: data[:extract]}.to_json
  end

  error
  get '/zip_code' do
    wikipedia = Article::Proxy.new
    zip_code = params[:zip_code]
    if zip_code.class == Fixnum then zip_code.to_s end
    latitude = zip_code.to_lat.to_f.round(3)
    longitude = zip_code.to_lon.to_f.round(3)
    data = wikipedia.find_article latitude, longitude
    Logger.new(STDOUT).info "Data successfully transported! #{data}. \nClass: #{data.class}"
    {status: 'ok', title: data['title'], extract: data['extract']}.to_json
  end
end
