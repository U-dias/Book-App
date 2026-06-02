class RenameBooktagsToBookTags < ActiveRecord::Migration[7.1]
  def change
    rename_table :booktags, :book_tags
  end
end
