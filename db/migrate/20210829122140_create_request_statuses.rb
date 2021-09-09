class CreateRequestStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :request_statuses do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
