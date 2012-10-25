require 'redis'
require 'yaml'

redis_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))['redis']
@redis = Redis.new(redis_config)
