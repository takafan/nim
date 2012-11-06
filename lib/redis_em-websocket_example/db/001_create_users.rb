class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username, limit: 32
      t.string :salt
      t.string :cpass
      t.string :email
      t.timestamps
    end

  end

  def down
    drop_table :users
  end

end
