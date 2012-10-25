require File.expand_path('../../config/ar.rb', __FILE__)

ActiveRecord::Migrator.migrate(File.expand_path('../../db', __FILE__))
