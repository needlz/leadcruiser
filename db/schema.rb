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

ActiveRecord::Schema.define(version: 20141013082612) do

  create_table "visitors", force: true do |t|
    t.string   "session_hash"
    t.integer  "site_id"
    t.string   "visitor_ip"
    t.string   "refferring_url"
    t.string   "refferring_domain"
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
