class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.references :employee, null: false, foreign_key: { to_table: :users, name: :fk_requests_employee_id }
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :status, null: false, foreign_key: { to_table: :request_statuses, name: :fk_requests_request_status_id }
      t.date :resolved_at, null: true
      t.timestamps
    end
  end
end
