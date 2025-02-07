class RemoveCumulativeHoursFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :cumulative_hours, :float
  end
end
