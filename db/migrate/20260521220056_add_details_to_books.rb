class AddDetailsToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :body, :text
    add_column :books, :rating, :integer
  end
end
