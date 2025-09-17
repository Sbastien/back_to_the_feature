class CreateRules < ActiveRecord::Migration[8.0]
  def change
    create_table :rules do |t|
      t.references :flag, null: false, foreign_key: true
      t.string :type
      t.string :value

      t.timestamps
    end
  end
end
