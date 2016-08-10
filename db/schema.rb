# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160729114024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "block_lists", force: :cascade do |t|
    t.string   "block_ip",    limit: 255
    t.boolean  "active"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cat_breeds", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clicks", force: :cascade do |t|
    t.string   "visitor_ip",               limit: 255
    t.integer  "clients_vertical_id"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clicks_purchase_order_id"
    t.string   "status",                   limit: 255
  end

  create_table "clicks_purchase_orders", force: :cascade do |t|
    t.integer  "clients_vertical_id"
    t.integer  "page_id"
    t.float    "price"
    t.float    "weight"
    t.boolean  "active"
    t.integer  "total_limit"
    t.integer  "total_count",         default: 0
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_cat_breed_mappings", force: :cascade do |t|
    t.integer  "breed_id"
    t.string   "integration_name", limit: 255
    t.string   "name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_breed_id"
  end

  create_table "client_dog_breed_mappings", force: :cascade do |t|
    t.integer  "breed_id"
    t.string   "integration_name", limit: 255
    t.string   "name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_breed_id"
  end

  create_table "clients_verticals", force: :cascade do |t|
    t.integer  "vertical_id"
    t.string   "integration_name",              limit: 255
    t.boolean  "active"
    t.integer  "weight"
    t.boolean  "exclusive"
    t.float    "fixed_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "service_url",                   limit: 255
    t.string   "request_type",                  limit: 255
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "email",                         limit: 255
    t.string   "phone_number",                  limit: 255
    t.string   "website_url",                   limit: 255
    t.string   "official_name",                 limit: 255
    t.text     "description"
    t.integer  "sort_order"
    t.boolean  "display",                                   default: true
    t.integer  "timeout",                                   default: 20
    t.integer  "lead_forwarding_delay_seconds",             default: 0
  end

  create_table "details_pets", force: :cascade do |t|
    t.string   "species",            limit: 255
    t.boolean  "spayed_or_neutered"
    t.string   "pet_name",           limit: 255
    t.string   "breed",              limit: 255
    t.integer  "birth_day",                      default: 1
    t.integer  "birth_month"
    t.integer  "birth_year"
    t.string   "gender",             limit: 255
    t.boolean  "conditions"
    t.integer  "lead_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dog_breeds", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editable_configurations", force: :cascade do |t|
    t.integer "gethealthcare_form_monitor_delay_minutes",          default: 30
    t.integer "gethealthcare_form_threshold_seconds",              default: 20
    t.text    "gethealthcare_notified_recipients_comma_separated"
    t.integer "forwarding_interval_minutes",                       default: 5
  end

  create_table "forwarding_time_ranges", force: :cascade do |t|
    t.string   "begin_day",  null: false
    t.time     "begin_time", null: false
    t.string   "end_day",    null: false
    t.time     "end_time",   null: false
    t.string   "kind",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gethealthcare_hits", force: :cascade do |t|
    t.string   "result"
    t.text     "last_error"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_id"
  end

  create_table "health_insurance_leads", force: :cascade do |t|
    t.integer  "lead_id"
    t.string   "boberdoo_type"
    t.text     "match_with_partner_id"
    t.text     "redirect_url"
    t.text     "src"
    t.string   "sub_id"
    t.string   "pub_id"
    t.string   "optout"
    t.string   "imbx"
    t.string   "ref"
    t.string   "user_agent"
    t.string   "tsrc"
    t.text     "landing_page"
    t.string   "skip_xsl"
    t.string   "test_lead"
    t.string   "fpl"
    t.integer  "age"
    t.integer  "height_feet"
    t.integer  "height_inches"
    t.integer  "weight"
    t.string   "tobacco_use"
    t.string   "preexisting_conditions"
    t.integer  "household_income"
    t.integer  "household_size"
    t.string   "qualifying_life_event"
    t.string   "spouse_gender"
    t.integer  "spouse_age"
    t.integer  "spouse_height_feet"
    t.integer  "spouse_height_inches"
    t.integer  "spouse_weight"
    t.string   "spouse_tobacco_use"
    t.string   "spouse_preexisting_conditions"
    t.string   "child_1_gender"
    t.integer  "child_1_age"
    t.integer  "child_1_height_feet"
    t.integer  "child_1_height_inches"
    t.integer  "child_1_weight"
    t.string   "child_1_tobacco_use"
    t.string   "child_1_preexisting_conditions"
    t.string   "child_2_gender"
    t.integer  "child_2_age"
    t.integer  "child_2_height_feet"
    t.integer  "child_2_height_inches"
    t.integer  "child_2_weight"
    t.string   "child_2_tobacco_use"
    t.string   "child_2_preexisting_conditions"
    t.string   "child_3_gender"
    t.integer  "child_3_age"
    t.integer  "child_3_height_feet"
    t.integer  "child_3_height_inches"
    t.integer  "child_3_weight"
    t.string   "child_3_tobacco_use"
    t.string   "child_3_preexisting_conditions"
    t.string   "child_4_gender"
    t.integer  "child_4_age"
    t.integer  "child_4_height_feet"
    t.integer  "child_4_height_inches"
    t.integer  "child_4_weight"
    t.string   "child_4_tobacco_use"
    t.string   "child_4_preexisting_conditions"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string   "session_hash",      limit: 255
    t.integer  "site_id"
    t.integer  "form_id",                       default: 1
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "address_1",         limit: 255
    t.string   "address_2",         limit: 255
    t.string   "city",              limit: 255
    t.string   "state",             limit: 255
    t.string   "zip",               limit: 255
    t.string   "day_phone",         limit: 255
    t.string   "evening_phone",     limit: 255
    t.string   "email",             limit: 255
    t.string   "best_time_to_call", limit: 255
    t.datetime "birth_date"
    t.string   "gender",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "times_sold"
    t.float    "total_sale_amount"
    t.integer  "vertical_id"
    t.string   "visitor_ip",        limit: 255, default: "127.1.1.1"
    t.string   "status",            limit: 255
    t.string   "disposition",       limit: 255
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "vertical_id"
    t.float    "weight"
    t.boolean  "exclusive"
    t.string   "states",                 limit: 255
    t.boolean  "preexisting_conditions"
    t.float    "price"
    t.string   "status",                 limit: 255
    t.boolean  "active"
    t.integer  "leads_max_limit"
    t.integer  "leads_daily_limit"
    t.integer  "leads_count_sold",                   default: 0
    t.integer  "daily_leads_count",                  default: 0
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  create_table "responses", force: :cascade do |t|
    t.text     "response"
    t.text     "rejection_reasons"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_id"
    t.string   "client_name",       limit: 255
    t.float    "price"
    t.integer  "purchase_order_id"
    t.float    "response_time"
  end

  create_table "sites", force: :cascade do |t|
    t.string   "domain",     limit: 255
    t.string   "host",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
  end

  create_table "tracking_pages", force: :cascade do |t|
    t.string   "link",                limit: 255
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clients_vertical_id"
  end

  create_table "transaction_attempts", force: :cascade do |t|
    t.integer  "lead_id"
    t.integer  "client_id"
    t.integer  "purchase_order_id"
    t.float    "price"
    t.boolean  "success"
    t.boolean  "exclusive_selling"
    t.text     "reason"
    t.integer  "response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "weight"
  end

  create_table "verticals", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "next_client", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "times_sold"
  end

  create_table "visitors", force: :cascade do |t|
    t.string   "session_hash",     limit: 255
    t.integer  "site_id"
    t.string   "visitor_ip",       limit: 255
    t.text     "referring_url"
    t.string   "referring_domain", limit: 255
    t.string   "landing_page",     limit: 255
    t.string   "keywords",         limit: 255
    t.string   "utm_medium",       limit: 255
    t.string   "utm_source",       limit: 255
    t.string   "utm_campaign",     limit: 255
    t.string   "utm_term",         limit: 255
    t.string   "utm_content",      limit: 255
    t.string   "location",         limit: 255
    t.string   "browser",          limit: 255
    t.string   "os",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zip_codes", force: :cascade do |t|
    t.integer  "zip"
    t.string   "primary_city", limit: 255
    t.string   "state",        limit: 255
    t.string   "timezone",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
