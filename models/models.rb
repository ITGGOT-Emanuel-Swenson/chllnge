require 'bcrypt' 
require 'sqlite3'
require 'securerandom'

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


class Repo

    def initialize(db, table, domain_object, columns)
        @db = db
        @table = table
        @domain_object = domain_object
        @columns = columns
    end

    def multi_column_query_gen(n)
        # for making sql query substitutions
        # create n "?, ?,...?, ?"
        
        # create the replace stuff (?,.. ?)
        # remove the trailing ', '
        replace_string = "?, " * n
        replace_string = replace_string.slice(0, replace_string.length - 2)
        return replace_string
    end

    def create(val_hash)
        # takes hash with arguments for columns to create the database row
        # if a column misses a value, then an error is raised
        #
        # {"username"=>"daser",
        #  "uuid"=>"ae021-123-zxxx",
        # }
        # hash is used for flexibility, hash.keys is identical to self.columns
        # otherwise error is raised

        # see if there are any missing columns in the hash given
        # raise error if there arent enough
        diff = val_hash.keys - @columns
        if diff != []
            raise "row creation failed, insufficient columns passed, #{diff} are missing"
        end
        
        replace_string = multi_column_query_gen(@columns.length)

        # example result
        # "INSERT INTO Profiles (user_id, uuid, title, content) VALUES (?, ?, ?, ?, ?)"
        query = "INSERT INTO #{@table} (#{@columns.join(", ")}) VALUES (#{replace_string})"
        p query
        p val_hash.values
        @db.execute(query, val_hash.values)
        
        # return the object created if uuid in val_hash
        # this will pretty much always be called
        if val_hash["uuid"]
            return get(val_hash["uuid"])
        end
    end
  
    # get domain object
    def get(uuid)
        return @domain_object.new(@db, @table, @columns, uuid)
    end
    # get all domain objects
    def all()
        query = "SELECT uuid FROM #{@table}"
        resp = @db.execute(query)
        resp.flatten!
        resp.map! {|uuid| get(uuid)}
        return resp
    end

    def search(column, value)
        # performa SELECT WHERE query 
        # verify that the hash doesnt contain any columns not included in @columns
        if [column] - @columns != []
            raise "Error, invalid column. column: #{column}, value:#{value}\n valid columns:#{@columns}"
        end
        query = "SELECT UUID FROM #{@table} WHERE #{column} = ?"
        p query
        resp = @db.execute(query, [value]).flatten
        resp.map! {|uuid| get(uuid)}
        return resp
    end
   
end

class DomainObject

    def initialize(db, table, columns, uuid)
        @db = db
        @table = table
        @columns = columns
        
        # veryify that the uuid is valid
        # @get the first column, if it isnt an empty array the uuid is valid
        @uuid = uuid
        if get(@columns.first) == []
            raise "Error: invalid uuid. no data at #{@columns.first}"
        end
    end

    def method_missing(method, *args)
        # conv symbol to string
        method = method.to_s
        # split into parts to find out what it supposed to do
        # first part is function and the other is the column
        # ex: 'get_username' => ['get', 'username']
        method_parts = method.split("_")
        
        # if the method is longer than 2 and the other part in method_parts is same as self.column
        # proceed
        # if not, call the original method_missing
        if method_parts.length == 2 and @columns.include?(method_parts[1]) 

            # find the operation and pass the column as argument 
            if method_parts[0] == "get"
                return get(method_parts[1])

            elsif method_parts[0] == "set"
                # self.set() requires one more argument, the first value in args 
                return set(method_parts[1], args[0])

            else
                super()
            end
        else
            super()
        end
        
    end
    
    # get column
    def get(column)
        # get value from column
        query = "SELECT #{column} FROM #{@table} WHERE uuid IS ?"
        resp = @db.execute(query, @uuid).flatten[0]
        return resp
    end

    def set(column, value)
        # set columns value
        query = "UPDATE #{@table} SET #{column} = ? WHERE uuid IS ?"
        @db.execute(query, [value, @uuid]).flatten

    end
    
    def delete()
        # delete column
        # only use for foreign key relationships
        query = "DELETE FROM #{@table} where uuid IS ?"
        @db.execute(query, [@uuid])
    end
end
class ProfileObject < DomainObject

    def initialize(db, table, uuid, columns, challenge_repo)
        @challenge_repo = challenge_repo
        super(db, table, uuid, columns)
    end
    
    def get_challenges()
        return @challenge_repo.search(column="user_id", value=@id)
    end

end
class ProfileRepo < Repo
    
    def initialize(db, table, uuid, columns, challenge_repo)
        @challenge_repo = challenge_repo
        super(db, table, uuid, columns)
    end
    
    def get(uuid)
        return @domain_object.new(@db, @table, @columns, uuid, @challenge_repo)
    end

end

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

class CommentObject < DomainObject

end

class CommentRepo < Repo
    
end

class DBHandler
    
    def initialize(db_path)
        @db = SQLite3::Database.new(db_path) 
        
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
