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

ActiveRecord::Schema[7.0].define(version: 2022_10_17_074225) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "graph_protocol_qlog_import_chunks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "qlog_import_id"
    t.integer "status"
    t.integer "sequence"
    t.bigint "range_start"
    t.bigint "range_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qlog_import_id"], name: "index_graph_protocol_qlog_import_chunks_on_qlog_import_id"
  end

  create_table "graph_protocol_qlog_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "query_set_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_set_id"], name: "index_graph_protocol_qlog_imports_on_query_set_id"
  end

  create_table "graph_protocol_queries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "query_set_id"
    t.string "query_id"
    t.string "subgraph"
    t.string "variables"
    t.text "query"
    t.float "offset"
    t.float "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_set_id", "offset"], name: "index_graph_protocol_queries_on_query_set_id_and_offset"
    t.index ["query_set_id", "subgraph", "offset"], name: "sort_by_subgraph"
    t.index ["query_set_id"], name: "index_graph_protocol_queries_on_query_set_id"
  end

  create_table "graph_protocol_query_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.string "import_type", null: false
    t.string "file_path", null: false
    t.string "query_set_type", null: false
  end

  create_table "graph_protocol_test_instances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "test_id"
    t.integer "status", default: 0
    t.datetime "started_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_id"], name: "index_graph_protocol_test_instances_on_test_id"
  end

  create_table "graph_protocol_tests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "query_set_id"
    t.integer "query_limit"
    t.integer "workers", default: 50
    t.string "subgraphs", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_set_id"], name: "index_graph_protocol_tests_on_query_set_id"
  end

end
