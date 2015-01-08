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

ActiveRecord::Schema.define(version: 20150108180758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "cat_breeds", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_cat_breed_mappings", force: true do |t|
    t.integer  "breed_id"
    t.string   "integration_name"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_dog_breed_mappings", force: true do |t|
    t.integer  "breed_id"
    t.string   "integration_name"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients_verticals", force: true do |t|
    t.integer  "vertical_id"
    t.string   "integration_name"
    t.boolean  "active"
    t.integer  "weight"
    t.boolean  "exclusive"
    t.float    "fixed_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "service_url"
    t.string   "request_type"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "email"
    t.string   "phone_number"
    t.string   "website_url"
    t.string   "official_name"
    t.text     "description"
    t.integer  "sort_order"
    t.boolean  "display",           default: true
  end

  create_table "details_pets", force: true do |t|
    t.string   "species"
    t.boolean  "spayed_or_neutered"
    t.string   "pet_name"
    t.string   "breed"
    t.integer  "birth_day",          default: 1
    t.integer  "birth_month"
    t.integer  "birth_year"
    t.string   "gender"
    t.boolean  "conditions"
    t.string   "list_of_conditions"
    t.integer  "lead_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dog_breeds", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ftp_leads", force: true do |t|
    t.integer  "lead_id"
    t.string   "sent_filename"
    t.datetime "sent_time"
    t.string   "received_filename"
    t.datetime "received_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leads", force: true do |t|
    t.string   "session_hash"
    t.integer  "site_id"
    t.integer  "form_id",           default: 1
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "day_phone"
    t.string   "evening_phone"
    t.string   "email"
    t.string   "best_time_to_call"
    t.datetime "birth_date"
    t.string   "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "times_sold"
    t.float    "total_sale_amount"
    t.integer  "vertical_id"
    t.string   "visitor_ip",        default: "127.1.1.1"
    t.string   "status"
  end

  create_table "leads_details_verticals", force: true do |t|
    t.integer  "lead_id"
    t.integer  "detail_id"
    t.integer  "vertical_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", force: true do |t|
    t.integer  "vertical_id"
    t.integer  "weight"
    t.boolean  "exclusive"
    t.string   "states"
    t.boolean  "preexisting_conditions"
    t.float    "price"
    t.string   "status"
    t.boolean  "active"
    t.integer  "leads_max_limit"
    t.integer  "leads_daily_limit"
    t.integer  "leads_count_sold"
    t.integer  "daily_leads_count"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  create_table "responses", force: true do |t|
    t.text     "response"
    t.string   "client_times_sold"
    t.string   "client_offer_amount"
    t.boolean  "client_offer_accept"
    t.text     "error_reasons"
    t.text     "rejection_reasons"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_id"
    t.string   "client_name"
    t.float    "price"
    t.integer  "purchase_order_id"
  end

  create_table "sites", force: true do |t|
    t.string   "domain"
    t.string   "host"
    t.string   "site_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "transaction_attempts", force: true do |t|
    t.integer  "lead_id"
    t.integer  "client_id"
    t.integer  "purchase_order_id"
    t.integer  "price"
    t.boolean  "success"
    t.boolean  "exclusive_selling"
    t.text     "reason"
    t.integer  "response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "weight"
  end

  create_table "verticals", force: true do |t|
    t.string   "name"
    t.string   "next_client"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "times_sold"
  end

  create_table "visitors", force: true do |t|
    t.string   "session_hash"
    t.integer  "site_id"
    t.string   "visitor_ip"
    t.string   "referring_url"
    t.string   "referring_domain"
    t.string   "landing_page"
    t.string   "keywords"
    t.string   "utm_medium"
    t.string   "utm_source"
    t.string   "utm_campaign"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "location"
    t.string   "browser"
    t.string   "os"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zip_codes", force: true do |t|
    t.integer  "zip"
    t.string   "primary_city"
    t.string   "state"
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
