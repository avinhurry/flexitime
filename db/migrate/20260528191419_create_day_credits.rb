class CreateDayCredits < ActiveRecord::Migration[8.1]
  def change
    create_table :day_credits do |t|
      t.references :user, null: false, foreign_key: true
      t.date :credit_date, null: false
      t.string :credit_type, null: false, default: "bank_holiday"
      t.integer :credited_minutes, null: false
      t.text :note

      t.timestamps
    end

    add_index :day_credits, [ :user_id, :credit_date ]
  end
end
