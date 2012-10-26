require File.expand_path('../../config/initializers/establish_connection.rb', __FILE__)

ActiveRecord::Migrator.migrate(File.expand_path('../../db', __FILE__))
