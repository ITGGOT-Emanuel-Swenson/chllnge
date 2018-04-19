require_relative 'base_model.rb'

class ProfileObject < DomainObject

    def get_challenges()
        challenge_repo = @foreign_domain_objects["challenge_repo"]
        return challenge_repo.search(column="user_id", value=@id)
    end

end
class ProfileRepo < Repo
    
end
