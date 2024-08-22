class CreateTimeEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :time_entries do |t|
      t.datetime :clock_in
      t.datetime :clock_out

      t.timestamps
    end
  end
end
