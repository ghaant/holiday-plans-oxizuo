class AddUniqueIndexToRequestStatuses < ActiveRecord::Migration[6.0]
  def change
    add_index :request_statuses, :name, unique: true
  end
end
