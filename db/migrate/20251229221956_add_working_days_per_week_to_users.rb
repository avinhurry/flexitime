class AddWorkingDaysPerWeekToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :working_days_per_week, :integer, null: false, default: 5
  end
end
