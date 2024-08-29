class AddLunchTimesToTimeEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :time_entries, :lunch_out, :datetime
    add_column :time_entries, :lunch_in, :datetime
  end
end
