# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_23_131655) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "graph_protocol_queries", force: :cascade do |t|
    t.bigint "query_set_id"
    t.string "query_id"
    t.string "subgraph"
    t.text "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "variables"
    t.float "offset"
    t.float "timestamp"
    t.index ["query_set_id", "offset"], name: "index_graph_protocol_queries_on_query_set_id_and_offset"
    t.index ["query_set_id", "subgraph", "offset"], name: "sort_by_subgraph"
    t.index ["query_set_id"], name: "index_graph_protocol_queries_on_query_set_id"
  end

  create_table "graph_protocol_query_sets", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["uuid"], name: "index_graph_protocol_query_sets_on_uuid", unique: true
  end

  create_table "graph_protocol_tests", force: :cascade do |t|
    t.string "uuid"
    t.string "integer"
    t.bigint "graph_protocol_query_set_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graph_protocol_query_set_id"], name: "index_graph_protocol_tests_on_graph_protocol_query_set_id"
    t.index ["uuid"], name: "index_graph_protocol_tests_on_uuid", unique: true
  end

  add_foreign_key "graph_protocol_tests", "graph_protocol_query_sets"
end
