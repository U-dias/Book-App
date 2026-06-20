class AddGoogleBooksIdToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :google_books_id, :string
  end
end
