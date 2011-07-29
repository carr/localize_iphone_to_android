class IphoneLocalizable
  def initialize(filename, options = {})
    puts "Loading #{filename}"
    @filename = filename
    @basename = File.basename(@filename)
    @locale = options[:locale] || File.basename(File.dirname(@filename)).gsub(".lproj", "")
#    @contents = File.open(filename, 'r')
    @data = []
    read
  end
  
  # read the input file and store in internal data structure
  def read
    x = nil
    File.open(@filename, 'r') {|f| x = f.readlines }
    x.each do |line|

      line = self.class.remove_comments(line)

      if line.present?
        @data << self.class.extract_data_from_line(line)
        puts self.class.extract_data_from_line(line).to_yaml
      end
    end
  end
  
  # remove everything that follows after "//"
  def self.remove_comments(string)
    string.gsub(/\/\/(.*)/, '')
  end
  
  def self.extract_data_from_line(line)
    raw = line.split('"').map(&:strip)

    original = format_value(convert_variables(raw[1]))
    value = format_value(convert_variables(raw[3]))

    data = {
      :key => original.gsub("+", "Plus").gsub("-", "Minus").gsub(" ", "_").gsub(/[^a-zA-Z0-9_]/, '').to_s, :value => value, :original => original
    }
  
    data
  end
  
  def self.convert_variables(string)
    string.gsub("%@", "%s").gsub("%u", "%d")
  end
  
  def self.format_value(string)
    return string # for wrt
    
    x = "\\"
    bla = "asdasdasdasdasd"
    string.gsub("'", x + bla + "'").gsub(bla, "")
  end
  
  def to_android(options = {})
    value_key = options[:original] ? :original : :value      

    $KCODE = 'UTF8'
    builder = Builder::XmlMarkup.new(:indent=>2)
    decoder = HTMLEntities.new
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"    
        
    xml = builder.resources do |resources|
      @data.each do |translation|
        resources.string(translation[value_key], :name => translation[:key])
      end
    end
    
#    puts xml
    decoder.decode(builder.target!)
  end
  
  def to_win7(options = {})
    value_key = options[:original] ? :original : :value      

    $KCODE = 'UTF8'
    builder = Builder::XmlMarkup.new(:indent=>2)
    decoder = HTMLEntities.new
    #builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"    
    
    xml = builder.mmaakknnii do |resources|
      @data.each do |translation|
        resources.data(:name => translation[:key]) do |bla|
          bla.value(translation[value_key])
        end
      end
    end    
    
    result = decoder.decode(builder.target!)
    result.gsub!('<mmaakknnii>', '').gsub!('</mmaakknnii>', '')
    

    f = File.read('OlxResources.resx')
    f.gsub('<!--- insert here --->', result)
#    puts xml
#    decoder.decode(builder.target!)
  end  
  
  def to_wrt(options = {})
    value_key = options[:original] ? :original : :value   
        
    str = ''
    str << "var olx;"
    str <<  "if (!olx || !olx.strings) {"
    str << 'alert("olx module has not been loaded");'
    str << '}'
    @data.each do |translation|
      str << "olx.strings[\"#{translation[:original]}\"] = \"#{translation[value_key]}\";\n"
    end
    
    str
  end
  
  def save_as_android!(options = {})
    FileUtils.mkdir_p android_directory
    File.open(File.join(android_directory, 'strings.xml'), 'w+') do |f|
      f.puts to_android(options)
    end
  end
  
  def save_as_win7!(options = {})
    FileUtils.mkdir_p win7_directory
    File.open(File.join(win7_directory, 'OlxResources.resx'), 'w+') do |f|
      f.puts to_win7(options)
    end    
  end
  
  def save_as_wrt!(options = {})
    FileUtils.mkdir_p wrt_directory
    File.open(File.join(wrt_directory, "localizedTextStrings.js"), 'w+') do |f|
      f.puts to_wrt(options)
    end    
  end  
  
  def android_directory
    "android/values-#{@locale}"
  end
  
  def win7_directory
    "win7/#{@locale}"
  end
  
  def wrt_directory
    "wrt/#{@locale}.lproj"
  end
end
