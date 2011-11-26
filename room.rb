require 'rubygems'
require 'sinatra'
require 'form'

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
    ], {:value => 'Upload!'}).to_s
    
  @footer = "Created by Vivek Bhagwat"
  
  erb :index
end

post '/upload/?' do
  urls = params[:urls]
  url_array = urls.split(/\s|\r/)
  @body = url_array.map{|url| '<img src="' + url.to_s + '" /><br />'}
  erb :index
end