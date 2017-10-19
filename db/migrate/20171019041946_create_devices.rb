class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :uid
      t.string :app_version, limit: 32
      t.string :os_name, limit: 32
      t.string :meta
      t.string :push_token
      t.boolean :push_alert
      t.boolean :active

      t.timestamps
    end
  end
end
