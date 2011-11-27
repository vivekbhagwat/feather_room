require 'rubygems'
require 'sinatra'
require 'mongo'
require 'bson'
require 'open-uri'

require 'form'
require 'photo'

connection = Mongo::Connection.new
db = connection.db("mydb")
grid = Grid.new(db)

get '/' do
  @title = "Feather Room"
  @footer = "Created by Vivek Bhagwat"
  erb :index
end

get '/hi' do
  "Hello, World!"
end

get '/upload/?' do
  @title = "Feather Room - Upload Photos"
  @body = '<h1>Upload Photos</h1>'
  @body += '<h2>Enter a bunch of URLs of photos to "upload"</h2>'
  # @body += '<textarea rows="4" cols="50" />'
  
  @body += Form.new('', 'POST', [
    {:content => '', :type => 'textarea', :name=>'urls'}
    ], {:value => 'Upload!'}).to_html
    
  @footer = "Created by Vivek Bhagwat"
  
  erb :index
end

post '/upload/?' do
  urls = params[:urls]
  url_array = urls.split(/\s|\r/)
  @body = ''
  url_array.each {|url| @body += '<img src="' + url.to_s + '" /><br />'}
  
  $photos = []
  
  url_array.each do |url|
    $photos << Photo.new(url.to_s)
    
    pic = $photos.last
    
    pic.id = grid.put(pic.data, :filename=>pic.filename)
    
    # grid.open db, pic.filename, 'w+' do |file|
    #       file.content_type = 'image/jpg'
    #       file.puts(pic.data)
    #     end
  end
  raise $photos.inspect
  
  
  @body += connection.database_names.inspect
  @body += '<br />'
  @body += connection.database_info.inspect
  @body += '<br />'
  @body += db.collection_names.inspect
  erb :index
end