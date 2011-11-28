class Form
  attr_accessor :action, :method, :content, :submit, :is_file
  
  def initialize(action='/',method='GET',content=[],submit={}, file=false)
    @action = action
    @method = method
    @content = content
    @submit = submit
    @is_file = file
  end
  
  
  # '<form action="@action" method="@method">
  # <input type="type1" value="value1" .. />
  # ...
  # <input type="submit" value="submit_value" ... />
  # </form>'
  def to_html
    enctype = 'enctype="multipart/form-data"' if @is_file
    enctype ||= ''
    
    str = '<form action="' + @action + '" method="' + @method + '" ' + enctype + '>'
    
    @content.each do |c|
      if c.is_a?Hash
        str += c[:content].to_s + '<input '
        (c.keys - [:content]).each do |input|
          str += input.to_s + '="' + c[input].to_s + '" '
        end
        str += " />\n"
      elsif c.nil?
        str += "<br />\n"
      end
    end
    
    str += '<input type="submit" '
    @submit.each do |k,v|
      str += k.to_s + '="' + v.to_s + '" '
    end
    str += '/>'
    
    str + '</form>'
  end
end