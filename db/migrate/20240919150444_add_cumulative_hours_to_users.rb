class AddCumulativeHoursToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :cumulative_hours, :float, default: 0.0
  end
end
