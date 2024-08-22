class AddLunchDurationToTimeEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :time_entries, :lunch_duration, :decimal
  end
end
