require 'active_record'
require 'yaml'

ar_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))['ar']
ActiveRecord::Base.establish_connection(ar_config)
