class RemoveLunchTimesFromTimeEntries < ActiveRecord::Migration[8.1]
  def change
    remove_column :time_entries, :lunch_in, :datetime
    remove_column :time_entries, :lunch_out, :datetime
  end
end
