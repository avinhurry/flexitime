class AddWeekEntriesTable < ActiveRecord::Migration[8.0]
  def change
    create_table :week_entries do |t|
      t.datetime :beginning_of_week
      t.integer :offset_in_minutes
      t.references :user, null: false, foreign_key: true
    end
  end
end
