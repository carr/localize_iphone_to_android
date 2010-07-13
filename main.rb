require 'rubygems'
require 'yaml'
require 'lib/iphone_localizable'
require 'htmlentities'

gem 'activesupport'
require 'active_support/all'

$KCODE = 'UTF8'

gem 'builder', '2.1.2'

input_files = Dir['iphone/*.strings'].sort

iphone = IphoneLocalizable.new(input_files.first, :locale => :en)
iphone.save_as_android!(:original => true)

input_files.each do |file|
  iphone = IphoneLocalizable.new(file)
  iphone.save_as_android!
end

