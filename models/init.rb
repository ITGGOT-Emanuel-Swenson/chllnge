require_relative 'models.rb'
require 'securerandom'
require 'sqlite3'
path = "chllnge.db"
dbh = DBHandler.new(path)
profiles = dbh.profiles
uuid = SecureRandom.uuid
dict = {"user_id" => "place", 
        "uuid" => uuid,
        "content" => "",
        "img_url" => "",
        "creation_date" => ""
        }
db = SQLite3::Database.new("chllnge.db")
au = Authentication
