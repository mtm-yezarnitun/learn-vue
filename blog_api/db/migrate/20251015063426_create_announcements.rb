class CreateAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :message
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :active

      t.timestamps
    end
  end
end
