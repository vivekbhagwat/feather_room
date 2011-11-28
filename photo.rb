require 'open-uri'
class Photo
  attr_accessor :filename, :data, :id, :file_ext, :height, :width, :aviary_response
  
  def initialize(file = nil, filename='')
    @filename = filename
    
    @data = file.read
    @id = nil
  end
  
  def to_html
    '<img src="/photos/' + id.to_s + '" />'
  end
  
end