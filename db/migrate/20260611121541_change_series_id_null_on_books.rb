class ChangeSeriesIdNullOnBooks < ActiveRecord::Migration[7.1]
  def change
    change_column_null :books, :series_id, true
  end
end
