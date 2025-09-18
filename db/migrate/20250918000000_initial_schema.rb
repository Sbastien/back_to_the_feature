class InitialSchema < ActiveRecord::Migration[8.0]
  def change
    # Users table
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.string :role, default: "user"

      t.timestamps
    end

    add_index :users, :username, unique: true

    # Flags table
    create_table :flags do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end

    add_index :flags, :name, unique: true

    # Rules table
    create_table :rules do |t|
      t.references :flag, null: false, foreign_key: true
      t.string :type
      t.string :value

      t.timestamps
    end

    # Groups table
    create_table :groups do |t|
      t.string :name, null: false
      t.text :definition, null: false

      t.timestamps
    end

    add_index :groups, :name, unique: true
  end
end
