class AddUserIdToTimeEntries < ActiveRecord::Migration[7.2]
  def change
    add_reference :time_entries, :user, null: false, foreign_key: true
  end
end
