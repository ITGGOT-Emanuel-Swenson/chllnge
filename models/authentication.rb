class Authentication
    
    def self.user_exists(db, username)
        query = "SELECT username FROM Accounts WHERE username IS ?"
        p username
        resp = db.execute(query, username)
        if resp != [] 
            return true
        else 
            return false
        end
    end
    
    def self.create_user(db, username, password)
        if not self.user_exists(db, username)
            hash = BCrypt::Password.create(password)
            query = "INSERT INTO Accounts (username, password) VALUES (?, ?)"
            db.execute(query, [username, hash])
            return true
        else
            return false
        end
    end


    def self.login_check(db, username, password)
        if self.user_exists(db, username)
            query = "SELECT password FROM Accounts WHERE username IS ?"
            hash = db.execute(query, username)[0][0]
            if hash
                user_password = BCrypt::Password.new(hash)
                # true if there is a password and it is correct
                return user_password == password
            else
                return false
            end
        else 
            return false
        end

    end
    def self.set_cookie(db, username)
       # only to be used with login
       # UPDATE Notes SET note= ? WHERE username IS ?
       query = "UPDATE Accounts SET cookie= ?, cookie_expiration= ?  WHERE username IS ?"
       # 2 weeks lifetime
       cookie_lifetime = 1209600
       # unix timestamp
       cookie_expiration = Time.new.utc.to_i + cookie_lifetime
       # random data to be cookied
       # raises spork
       cookie = rand().to_s

       db.execute(query, [cookie, cookie_expiration, username])
       p cookie
       return cookie
    end
    
    def self.cookie_match(db, username, cookie)
        # checks if cookie is valid, returns true if that is the case
        if self.user_exists(db, username)
            # check if user has this cookie
            query = "SELECT cookie FROM Accounts WHERE username IS ?"
            user_cookie = db.execute(query, username)
            
            if cookie == user_cookie
                return True
            else
                return False
            end
        else
            return false
        end
    end
    
end


