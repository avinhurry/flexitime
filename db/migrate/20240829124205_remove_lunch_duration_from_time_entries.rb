class RemoveLunchDurationFromTimeEntries < ActiveRecord::Migration[7.2]
  def change
    remove_column :time_entries, :lunch_duration, :decimal
  end
end
