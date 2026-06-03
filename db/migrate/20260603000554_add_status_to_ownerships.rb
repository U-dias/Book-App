class AddStatusToOwnerships < ActiveRecord::Migration[7.1]
  def change
    add_column :ownerships, :status, :integer
  end
end
