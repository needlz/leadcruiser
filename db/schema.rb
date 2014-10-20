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

ActiveRecord::Schema.define(version: 20141017110531) do

  create_table "clients_verticals", force: true do |t|
    t.integer  "vertical_id"
    t.string   "integration_name"
    t.boolean  "active"
    t.integer  "weight"
    t.boolean  "exclusive"
    t.float    "fixed_price"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "visitor_ip",         default: "127.1.1.1"
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
    t.string   "visitor_ip",         default: "127.1.1.1"
  end

  create_table "leads_details_verticals", force: true do |t|
    t.integer  "lead_id"
    t.integer  "detail_id"
    t.integer  "vertical_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "sites", force: true do |t|
    t.string   "domain"
    t.string   "host"
    t.string   "site_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
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

end
