require_relative 'comments.rb'
require_relative 'challenges.rb'
require_relative 'profiles.rb'
require_relative 'accounts.rb'
require_relative 'database.rb'
require_relative 'authentication.rb'

class DBHandler

    def initialize(db_path)
        database = DataBase.new(db_path)
        @db = database.db

        @comments_repo = CommentRepo.new(
            db=@db,
            table="Comments",
            domain_object=CommentObject,
            columns=["user_id", "uuid", "challenge_id", "content", "creation_date"], 
            identifier_column = 'UUID'
            )
        @challenges_repo = ChallengeRepo.new(
            db=@db,
            table="Challenges",
            domain_object=ChallengeObject,
            columns=["user_id", "uuid", "title", "content", "creation_date"],
            identifier_column='UUID',
            foreign_domain_objects = {"comments_repo" => @comments_repo}
            )
            
        @profiles_repo = ProfileRepo.new(
            db=@db, 
            table="Profiles", 
            domain_object=ProfileObject, 
            columns = ["user_id", "uuid", "content", "img_url", "creation_date"],
            identifier_column='UUID', 
            foreign_domain_objects = {"challenges_repo" => @challenges_repo}
            )
        
        acc_repo = AccountRepo.new(
            db=@db, 
            table='Accounts', 
            domain_object=AccountObject, 
            columns=["username", "password", "date_joined"], 
            identifier_column='username'
            )
        @auth = Authentication.new(acc_repo)
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


