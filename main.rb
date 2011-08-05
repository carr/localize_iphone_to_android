require 'rubygems'
require 'fileutils'
require 'yaml'
require 'lib/iphone_localizable'
require 'htmlentities'
require 'builder'
gem 'activesupport'
require 'active_support/all'

$KCODE = 'UTF8'

input_files = Dir['iphone/**/Localizable.strings'].sort

# input_files = Dir['iphone/hr*/Localizable.strings']

# iphone = IphoneLocalizable.new(input_files.first)
# puts input_files.first
# iphone.save_as_android!

input_files.each do |file|
  iphone = IphoneLocalizable.new(file)
  iphone.save_as_android!
  # iphone.save_as_android!(:original => true)
  # iphone.save_as_win7!
end

