require_relative 'comments.rb'
require_relative 'challenges.rb'
require_relative 'profiles.rb'
require_relative 'database.rb'
require_relative 'authentication.rb'

class DBHandler

    def initialize(db_path)
        database = Database.new(db_path)
        @db = database.db

        @comments_repo = CommentRepo.new(@db, "Comments", CommentObject, ["user_id", "challenge_id", "uuid", "content", "img_url", "creation_date"], 'UUID')
        @challenges_repo = ChallengeRepo.new(@db, "Challenges", ChallengeObject, ["user_id", "uuid", "content", "img_url"], 'UUID', @comments_repo)
        @profiles_repo = ProfileRepo.new(@db, "Profiles", ProfileObject, ["user_id", "uuid", "content", "img_url", "creation_date"], 'UUID', @challenges_repo)
        
        authentication_repo = Repo.new(@db, 'Accounts', DomainObject, ["username", "password", "date_joined"], 'username')
        @auth = Authentication.new(authentication_repo)
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

    def auth
        return @auth
    end
end


