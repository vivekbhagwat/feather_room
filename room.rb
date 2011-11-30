require 'rubygems'
require 'sinatra'
require 'mongo'
require 'bson'
require 'mongo/gridfs/grid'
require 'open-uri'
require 'aviary_fx'

require 'form'
require 'photo'

connection = Mongo::Connection.new
db = connection.db("mydb")
grid = Mongo::Grid.new(db)

afx = AviaryFX::API.new("93aa546bf", "644814880")

$photos = {}
effects = afx.get_filters()
effects_hash = {}
effects.each do |e|
  effects_hash[e.uid] = e
end

get '/' do
  @title = "Feather Room"
  # @footer = "Created by Vivek Bhagwat"
  erb :index
end

get '/hi' do
  "Hello, World!"
end

get '/upload/?' do
  @title = "Feather Room - Upload Photos"
  @body = '<h2>Upload Photos</h2>'
  @body += '<h3>Enter a bunch of URLs of photos to "upload"</h3>'
  
  @body += Form.new('', 'POST', [
    {:content => '', :type => 'file', :multiple=>"true", :name=>'urls[]'}
    ], {:value => 'Upload!'}, true).to_html
    
  # @footer = "Created by Vivek Bhagwat"
  
  erb :index
end

post '/upload/?' do
  urls = params[:urls]
  # url_array = urls.split(/\s|\r/)
  # @body = ''
  # url_array.each {|url| @body += '<img src="' + url.to_s + '" /><br />'}
  
  
  urls.each do |url|
    pic = Photo.new(url[:tempfile], url[:filename])
    pic.aviary_response = afx.upload(url[:tempfile].path)
    pic.id = grid.put(pic.data, :filename=>pic.filename)    
    $photos[pic.id.to_s] = pic
  end
  
  redirect('/photos/edit')
end

get '/photos/edit/?' do
  f = Form.new('/photos/edit', 'POST', [], {:value=>'EDIT!'})
  $photos.each do |id, p|
    f.content << { :content => p.to_html,
      :type => 'checkbox', :name=> id.to_s
    }
  end
  f.content << [nil, nil]
  
  effects.each do |e|
    f.content << {:content => '<br />' + e.label,
      :type => 'checkbox', :name => e.uid}
  end
  
  @body = '<h2>Select which filters to apply to which photos</h2>' + f.to_html
  
  erb :index
end

post '/photos/edit/?' do
  selected_photos = []
  updated_photos = []
  selected_effects = []
  params.keys.each do |param|
    if BSON::ObjectId.legal?(param)
      selected_photos << $photos[param]
      # afx.upload()
    else
      selected_effects << param.to_s
    end
  end
  
  backgroundcolor = "0xFFFFFFFF"
  format = "png"
  quality = "100"
  scale = "1"
  width = "0"
  height = "0"

  selected_photos.each do |pic|
    filepath = pic.aviary_response[:url]
    selected_effects.each do |effect_id|      
      rpc = AviaryFX::RenderParameterCollection.new({
        :parameters => effects_hash[effect_id].parameters
        })
      
      p backgroundcolor
      p format
      p quality
      p scale
      puts '
      
      '
      p filepath #something is wrong with this response I'm getting.
      puts '
      
      
      '
      p effect_id
      p width
      p height
      p rpc
      
      # rpc = AviaryFX::RenderParameterCollection.new_from_json(render_parameters = '{
      #    "parameters":  [
      #      { "id" : "Text Top", "value" : "asdfasdfasdf"},
      #      { "id" : "Text Bottom", "value" : "OR JUST STUPID"}
      #    ]
      # }')
      # puts ''
      # p rpc
      
      filepath = 'http://images.aviary.com/imagesv5/aviary_button.png'
      
      updated_photos << afx.render(backgroundcolor, format, quality, scale, filepath, effect_id, width, height, rpc)[:url]
    end
  end
  

  
  
  (selected_photos + selected_effects).inspect + "<br />" + updated_photos.inspect
end

get '/photos/:id/?' do
  grid.get(BSON::ObjectId.from_string(params[:id])).read
end


class Hash
  def slice(*keys)
    {}.tap{ |h| keys.each{ |k| h[k] = self[k] } }
  end
end

ENV_COPY  = %w[ REQUEST_METHOD HTTP_COOKIE rack.request.cookie_string
                rack.session rack.session.options rack.input]

# Returns the response body after simulating a request to a particular URL
# Maintains the session of the current user.
# Pass custom headers if you want to set or change them, e.g.
#
#  # Spoof a GET request, even if we happen to be inside a POST
#  html = spoof_request "/partial/assignedto/#{@bug.id}", 'REQUEST_METHOD'=>'GET'
def spoof_request( uri, headers=nil )
  new_env = env.slice(*ENV_COPY).merge({
    "PATH_INFO"    => uri.to_s,
    "HTTP_REFERER" => env["REQUEST_URI"]
  })
  new_env.merge!(headers) if headers
  call( new_env ).last.join 
end
