class CreateFlags < ActiveRecord::Migration[8.0]
  def change
    create_table :flags do |t|
      t.string :name, null: false
      t.text :description
      t.json :variants, default: [
        { name: "A", weight: 50 },
        { name: "B", weight: 50 }
      ]

      t.timestamps
    end

    add_index :flags, :name, unique: true
  end
end
