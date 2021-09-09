# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_29_160527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "request_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_request_statuses_on_name", unique: true
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.bigint "status_id", default: 1, null: false
    t.date "resolved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["employee_id"], name: "index_requests_on_employee_id"
    t.index ["status_id"], name: "index_requests_on_status_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "manager_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["manager_id"], name: "index_users_on_manager_id"
  end

  add_foreign_key "requests", "request_statuses", column: "status_id", name: "fk_requests_request_status_id"
  add_foreign_key "requests", "users", column: "employee_id", name: "fk_requests_employee_id"
  add_foreign_key "users", "users", column: "manager_id", name: "fk_users_manager_id"
end
