require 'yaml'

@configurations = YAML.load_file(File.expand_path('../../configurations.yml', __FILE__))
