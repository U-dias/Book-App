class RenameReadhistoriesToReadHistories < ActiveRecord::Migration[7.1]
  def change
    rename_table :readhistories, :read_histories
  end
end
