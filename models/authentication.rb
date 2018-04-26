require_relative 'base_model.rb'
require 'time'

# where an uuid is normaly used, username is used instead
class Authentication
    def initialize(authentication_repo)
        @repo = authentication_repo
    end

    def user_exists(username)
        return @repo.get(username)
    end
    
    def create_user(username, password)
        if not user_exists(username)
            hash = BCrypt::Password.create(password)
            date_joined = Time.now().to_s
            val_hash = {
            'username' => username,
            'password' => hash,
            'date_joined' => date_joined,
            }
            return @repo.create(val_hash)
        else
            # user already exist
            return false
        end
    end

    def login_check(username, password)
        begin 
            user = @repo.get(username)
            hash = user.get_password 
            if hash
                user_password = BCrypt::Password.new(hash)
                # true if there is a password and it is correct
                return user_password == password
            else
                return false
            end
        rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
            return false
        end
    end
    def user_authorized(session_cookie)
        return user_exists(session_cookie)
    end
end

