require_relative 'base_model.rb'

class CompletedChallengesObject < DomainObject
    
end

class CompletedChallengesRepo < Repo

    def get_challenges_by_user_id(user_id)
        # challenges completed by user
        puts "SEARCH BY USER ID "
        resp = search("user_id", user_id)
        challenges_repo = @foreign_domain_objects['challenges_repo']
        p "before map"
        p resp
        resp.map! {|compchall| challenges_repo.get(compchall.get_challenge_id) }
        p "after map"
        p resp
        return resp
    end
end
