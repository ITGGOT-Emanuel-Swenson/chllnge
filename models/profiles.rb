require_relative 'base_model.rb'

class ProfileObject < DomainObject

    def initialize(db, table, uuid, columns, identifier_label, challenge_repo)
        @challenge_repo = challenge_repo
        super(db, table, uuid, columns)
    end
    
    def get_challenges()
        return @challenge_repo.search(column="user_id", value=@id)
    end

end
class ProfileRepo < Repo
    
    def initialize(db, table, uuid, columns, identifier_label, challenge_repo)
        @challenge_repo = challenge_repo
        super(db, table, uuid, columns)
    end
    
    def get(uuid)
        return @domain_object.new(@db, @table, @columns, uuid, @challenge_repo)
    end

end
