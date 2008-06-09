# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "announcements", :force => true do |t|
    t.string   "subject",                           :null => false
    t.text     "contents"
    t.boolean  "published",      :default => false
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "for_conference", :default => false
    t.boolean  "for_festival",   :default => false
  end

  create_table "festivals", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "location"
    t.string   "url"
    t.string   "film_url_format"
    t.date     "starts"
    t.date     "ends"
    t.boolean  "public",          :default => false
    t.boolean  "scheduled",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_conference",   :default => false
  end

  create_table "films", :force => true do |t|
    t.integer  "festival_id",  :limit => 11, :null => false
    t.string   "name"
    t.text     "description"
    t.string   "url_fragment"
    t.integer  "duration",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "countries"
    t.text     "amazon_data"
    t.text     "amazon_ad"
    t.string   "amazon_url"
  end

  create_table "picks", :force => true do |t|
    t.integer "user_id",      :limit => 11, :null => false
    t.integer "film_id",      :limit => 11, :null => false
    t.integer "festival_id",  :limit => 11, :null => false
    t.integer "screening_id", :limit => 11
    t.integer "priority",     :limit => 11
  end

  create_table "questions", :force => true do |t|
    t.string   "email"
    t.text     "question"
    t.boolean  "acknowledged", :default => false
    t.boolean  "done",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "screenings", :force => true do |t|
    t.integer  "festival_id", :limit => 11, :null => false
    t.integer  "film_id",     :limit => 11, :null => false
    t.integer  "venue_id",    :limit => 11, :null => false
    t.datetime "starts",                    :null => false
    t.datetime "ends",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscriptions", :force => true do |t|
    t.integer "festival_id", :limit => 11,                    :null => false
    t.integer "user_id",     :limit => 11,                    :null => false
    t.boolean "admin",                     :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "identity_url"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "admin",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", :force => true do |t|
    t.integer "festival_id", :limit => 11, :null => false
    t.string  "name"
    t.string  "abbrev"
  end

end
