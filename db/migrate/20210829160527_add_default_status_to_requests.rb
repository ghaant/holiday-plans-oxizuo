class AddDefaultStatusToRequests < ActiveRecord::Migration[6.0]
  def change
    change_column_default :requests, :status_id, RequestStatus.find_by(name: 'pending').id
  end
end
