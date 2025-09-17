class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :definition, null: false

      t.timestamps
    end

    add_index :groups, :name, unique: true
  end
end
