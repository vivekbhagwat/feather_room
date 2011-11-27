require 'open-uri'
class Photo
  attr_accessor :filename, :data, :id
  
  def initialize(filename='')
    @filename = filename
    
    @data = open(filename.to_s) {|f| f.read}
    @id = nil
  end
  
end