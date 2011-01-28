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

ActiveRecord::Schema.define(:version => 20110123030413) do

  create_table "announcements", :force => true do |t|
    t.string   "subject",                         :null => false
    t.text     "contents"
    t.boolean  "published",    :default => false
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "announcements", ["published", "published_at"], :name => "index_announcements_on_published_and_published_at"

  create_table "buzz", :force => true do |t|
    t.integer  "film_id",      :null => false
    t.integer  "user_id",      :null => false
    t.text     "content"
    t.string   "url"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "buzz", ["film_id", "published_at"], :name => "index_buzz_on_film_id_and_published_at"

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
    t.datetime "revised_at"
    t.string   "slug_group"
  end

  add_index "festivals", ["ends", "public"], :name => "index_festivals_on_ends_and_public"
  add_index "festivals", ["slug", "public"], :name => "index_festivals_on_slug_and_public"
  add_index "festivals", ["slug_group", "public"], :name => "index_festivals_on_slug_group_and_public"
  add_index "festivals", ["starts", "public"], :name => "index_festivals_on_starts_and_public"

  create_table "films", :force => true do |t|
    t.integer  "festival_id",  :null => false
    t.string   "name"
    t.text     "description"
    t.string   "url_fragment"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "countries"
  end

  add_index "films", ["festival_id"], :name => "index_films_on_festival_id"

  create_table "picks", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "film_id",      :null => false
    t.integer  "festival_id",  :null => false
    t.integer  "screening_id"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "picks", ["user_id", "festival_id"], :name => "index_picks_on_user_id_and_festival_id"

  create_table "questions", :force => true do |t|
    t.string   "email"
    t.text     "question"
    t.boolean  "acknowledged", :default => false
    t.boolean  "done",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "screenings", :force => true do |t|
    t.integer  "festival_id", :null => false
    t.integer  "film_id",     :null => false
    t.integer  "venue_id",    :null => false
    t.datetime "starts",      :null => false
    t.datetime "ends",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "press"
  end

  add_index "screenings", ["festival_id"], :name => "index_screenings_on_festival_id"

  create_table "subscriptions", :force => true do |t|
    t.integer  "festival_id",                                        :null => false
    t.integer  "user_id",                                            :null => false
    t.boolean  "admin",                           :default => false
    t.boolean  "show_press"
    t.text     "time_restrictions"
    t.string   "key",               :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "excluded_venues"
  end

  add_index "subscriptions", ["festival_id", "user_id"], :name => "index_subscriptions_on_festival_id_and_user_id"

  create_table "users", :force => true do |t|
    t.string   "username"
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

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "venues", :force => true do |t|
    t.integer  "festival_id", :null => false
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group"
  end

  add_index "venues", ["festival_id"], :name => "index_venues_on_festival_id"

end
