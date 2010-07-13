class IphoneLocalizable
  def initialize(filename, options = {})
    @filename = filename
    @basename = File.basename(@filename)
    @locale = options[:locale] || @basename.match(/(.*)_Localizable.strings/)[1]
    @contents = File.read(filename)
    @data = []
    read
  end
  
  # read the input file and store in internal data structure
  def read
    @contents.split("\n").each do |line|
      line = self.class.remove_comments(line)
      if line != ''
        @data << self.class.extract_data_from_line(line)
      end
    end
  end
  
  # remove everything that follows after "//"
  def self.remove_comments(string)
    string.gsub(/\/\/(.*)/, '')
  end
  
  def self.extract_data_from_line(line)
    raw = line.split('"').map(&:strip)
    data = {
      :key => raw[1].parameterize.gsub(/-/, "_").to_s, :value => raw[3], :original => raw[1]
    }
    data
  end
  
  def to_android(options = {})
    value_key = options[:original] ? :original : :value      

    builder = Builder::XmlMarkup.new(:indent=>2)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"utf-8"    
        
    xml = builder.resources do |resources|
      @data.each do |translation|
        resources.string(translation[value_key], :name => translation[:key])
      end
    end
    
    xml.to_s
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