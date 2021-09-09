class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.references :manager, null: true, foreign_key: { to_table: :users, name: :fk_users_manager_id }
      t.timestamps
    end
  end
end
