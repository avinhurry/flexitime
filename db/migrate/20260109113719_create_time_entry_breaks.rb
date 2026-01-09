class CreateTimeEntryBreaks < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entry_breaks do |t|
      t.references :time_entry, null: false, foreign_key: true
      t.datetime :break_in
      t.datetime :break_out
      t.string :reason

      t.timestamps
    end
  end
end
