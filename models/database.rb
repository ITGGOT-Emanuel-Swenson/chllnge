class DataBase
    def initialize(db_path)
        @db = SQLite3::Database.new(db_path)
    end

    def db
        return @db
    end
end

