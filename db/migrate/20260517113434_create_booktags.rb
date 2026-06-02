class CreateBooktags < ActiveRecord::Migration[7.1]
  def change
    create_table :booktags do |t|
      t.references :book, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
