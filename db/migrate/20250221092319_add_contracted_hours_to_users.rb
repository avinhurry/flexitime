class AddContractedHoursToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :contracted_hours, :integer, default: 37
  end
end
