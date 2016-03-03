require './wikipedia/loader'

class App < Sinatra::Base
  before do
    content_type 'application/json'
  end

  get '/' do
    wikipedia = Article::Proxy.new
    begin
      if params.has_key?('lat') && params.has_key?('lon')
        latitude = params[:lat].to_f
        longitude = params[:lon].to_f
      else
        zipcode = params[:zipcode].to_s
        latitude = zipcode.to_lat.to_f.round(3)
        longitude = zipcode.to_lon.to_f.round(3)
      end
    rescue StandardError => e
      status 400
      Logger.new(STDOUT).warn '400 raised'
      'Looks like you gave a bad request- please try again after changing your URL'
    else
      data = wikipedia.find_article latitude, longitude
      Logger.new(STDOUT).info "Data is #{data}."
      {status: data['status'], title: data['title'], extract: data['extract']}.to_json
    end
  end
end
