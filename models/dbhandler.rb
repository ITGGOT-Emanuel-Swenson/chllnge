require_relative 'comments.rb'
require_relative 'challenges.rb'
require_relative 'profiles.rb'

class DataBase
    def initialize(db_path)
        @db = SQLite3::Database.new(db_path)
    end

    def db
        return @db
    end
end

class DBHandler

    def initialize(db)

        @comments_repo = CommentRepo.new(@db, "Comments", CommentObject, ["user_id", "challenge_id", "uuid", "content", "img_url", "creation_date"])
        @challenges_repo = ChallengeRepo.new(@db, "Challenges", ChallengeObject, ["user_id", "uuid", "content", "img_url"], @comments_repo)
        @profiles_repo = ProfileRepo.new(@db, "Profiles", ProfileObject, ["user_id", "uuid", "content", "img_url", "creation_date"], @challenges_repo)
    end

    def comments
        return @comments_repo
    end
    def profiles
        return @profiles_repo
    end
    def challenges
        return @challenges_repo
    end
end


