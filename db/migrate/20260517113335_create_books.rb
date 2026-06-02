class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.references :series, null: false, foreign_key: true
      t.integer :volume

      t.timestamps
    end
  end
end
