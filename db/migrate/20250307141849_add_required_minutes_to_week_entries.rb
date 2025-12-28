class AddRequiredMinutesToWeekEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :week_entries, :required_minutes, :integer, null: false, default: 0
  end
end
