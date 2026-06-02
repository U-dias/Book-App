class CreateOwnerships < ActiveRecord::Migration[7.1]
  def change
    create_table :ownerships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.boolean :read

      t.timestamps
    end
  end
end
