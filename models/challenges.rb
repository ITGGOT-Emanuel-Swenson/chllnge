require_relative 'base_model.rb'

class ChallengeObject < DomainObject
    
    def get_comments()
        comments_repo = @foreign_domain_objects["comments_repo"]
        return comments_repo.search(column="challenge_id", value=@uuid)
    end
    
end

class ChallengeRepo < Repo
    
end
