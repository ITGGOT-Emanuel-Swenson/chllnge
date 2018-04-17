require_relative 'base_model.rb'

class ChallengeObject < DomainObject
    
    def initialize(db, table, uuid, columns, comment_repo)
        @comment_repo = comment_repo
        super(db, table, uuid, columns)
    
    end

    def get_comments()
        return comment_repo.search(column="challenge_id", value=@uuid)
    end
    
end

class ChallengeRepo < Repo
    
    def initialize(db, table, uuid, columns, comment_repo)
        @comment_repo = comment_repo
        super(db, table, uuid, columns)
    
    end

    # get domain object
    def get(uuid)
        return @domain_object.new(@db, @table, uuid, @columns, @comment_repo)
    end
end
