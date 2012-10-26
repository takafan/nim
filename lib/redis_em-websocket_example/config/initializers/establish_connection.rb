require 'active_record'
require File.expand_path('../configurations.rb', __FILE__)

ActiveRecord::Base.establish_connection(@configurations['ar'])
