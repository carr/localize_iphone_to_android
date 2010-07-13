class IphoneLocalizable
  def initialize(filename, options = {})
    puts "Loading #{filename}"
    @filename = filename
    @basename = File.basename(@filename)
    @locale = options[:locale] || @basename.match(/(.*)_Localizable.strings/)[1]
#    @contents = File.open(filename, 'r')
    @data = []
    read
  end
  
  # read the input file and store in internal data structure
  def read
    x = nil
    File.open(@filename, 'r') {|f| x = f.readlines }
    x.each do |line|
      puts line
      line = self.class.remove_comments(line)
puts line
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

    original = convert_variables(raw[1])
    value = convert_variables(raw[3])

    data = {
      :key => original.parameterize.gsub(/-/, "_").to_s, :value => value, :original => original
    }
  
    data
  end
  
  def self.convert_variables(string)
    string.gsub("%@", "%s")
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
  
  def save_as_android!(options = {})
    FileUtils.mkdir_p android_directory
    File.open(File.join(android_directory, 'strings.xml'), 'w+') do |f|
      f.puts to_android(options)
    end
  end
  
  def android_directory
    "android/values-#{@locale}"
  end
end
