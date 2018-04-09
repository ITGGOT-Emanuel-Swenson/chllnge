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
        query = "SELECT password FROM Accounts WHERE username IS ?"
        hash = db.execute(query, username)[0][0]
        if hash
            user_password = BCrypt::Password.new(hash)
            # true if there is a password and it is correct
            return user_password == password
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

class DBHandler
    def initialize(db_path)
        self.db = sqlite3::database.new(db_name) 
    end

    def object_mapper(uuid_array, &block)
        # take array of uuids and create array of objects instead
        uuid_array.map! {|uuid| }
        
    end
    
    def new_profile(user_id, uuid, content, img_url)
        # create and recieve uuid
        return profile(uuid)
    end
    def profile(uuid)
        return Profile(self.db, uuid)
    end
    
    def new_challenge(user_id, title, content)
        # create and recieve uuid
        return challenge(uuid)
    end
    def challenge(uuid)
        return Challenge(self.db, uuid)
    end
    
    def new_comment(user_id, challenge_id, content)
        # create and recieve uuid
        return comment(uuid)
    end
    def comment(uuid)
        return Comment(self.db, uuid)
    end
end

class DataObject
    def self.initialize(db, table)

    
    end

    # largely useless method, will be overwritten by children
    # columns should be specified directly when passing parameters to function
    # just passing parameters blindly, ("id", "ase-213-xx2", "hello there"), is bad design
    def self.create(*args)
        # take all columns and create a string of them, sans quotes "id, name"
        columns_string = self.columns.join(", ")
        # the create the replace stuff (?,.. ?)
        replace_string = "?, " * self.columns.length
        # remove trailing ', '
        replace_string.slice!(0, replace_string.length - 2)
        query = "INSERT INTO ? ({columns_string}) VALUES ({replace_string})"
        self.db.execute(query, args)
    end
end

class DataObjectInstance

    def self.initialize(db, table, uuid, *columns)
        self.db = db
        self.table = table
        self.uuid = uuid
        self.columns = columns
    end
    
    def self.method_missing(method, *args)
        # conv symbol to string
        method = method.to_s
        # split into parts to find out what it supposed to do
        # first part is function and the other is the column
        # ex: 'get_username' => ['get', 'username']
        method_parts = method.split("_")
        
        # if the method is longer than 2 and the other part in method_parts is same as self.column
        # proceed
        # if not, call the original method_missing
        if method_parts.length == 2 and self.column == method_parts[1]

            # find the operation and pass the column as argument 
            if method_parts[0] == "get"
                return self.get(method_parts[1])

            elsif method_parts[0] == "set"
                # self.set() requires one more argument, the first value in args 
                return self.set(method_parts[1], args[0])

            else
                super()
            end
        else
            super()
        end
        
    end

    
    def self.get(column)
        # get value from column
        query = "SELECT ? FROM ? WHERE uuid IS ?"
        resp = self.db.execute(query, [column, self.table, self.uuid])
        return resp
    end

    def self.set(column, value)
        # set columns value
        query = "UPDATE ? SET ? = ? WHERE uuid IS ?"
        self.db.execute(query, [self.table, column, value, self.uuid])
    end
    
    def self.delete()
        # delete column
        # only use for foreign key relationships
        query = "DELETE FROM ? where uuid IS ?"
        self.db.execute(query, [self.table, self.uuid])
    end
end
class ProfileObject << DataObject

end
class Profile
    def self.create(db, username)
        # create profile
        query = "INSERT INTO Profiles (user_id, uuid, content, img_url) VALUES (?, ?, ?, ?)"
        
        uuid = SecureRandom.uuid()
        content = ""
        img_url = ""
        self.db.execute(query, [username, uuid, content, img_url])

        return ProfileObject(self.db, uuid)
    end
    def self.get(uuid)
    
    end
    def self.all(db)
        query = "SELECT uuid FROM Profiles"
        resp = self.db.execute(query)[]
        p resp
        resp.map! {|uuid| Profile(self.db, uuid) }
        return resp
    end

end
class ProfileObject
    def initialize(db, uuid)
        self.db = db
        self.uuid = uuid
        self.column
    end
    
    # get info 
    

    def self.get_username()
        query = "SELECT username FROm Profiles WHERE uuid IS ?"
        resp = self.db.execute(query, uuid)
        return resp
    end
    
    def self.get_content()
        query = "SELECT content FROM Profiles WHERE uuid IS ?"
        resp = self.db.execute(query, uuid)
        return resp
    end
    
    def self.get_img_url()
        query = "SELECT img_url FROM Profiles WHERE uuid IS ?"
        resp = self.db.execute(query, uuid)
        return resp
    end


    # update info
    def self.update_content(new_content)
       query = "UPDATE Profiles SET content= ? WHERE uuid IS ?"
       self.db.execute(query, [new_content, uuid])
    end
    
    def self.update_img_url()
       query = "UPDATE Profiles SET content= ? WHERE uuid IS ?"
       self.db.execute(query, [new_content, uuid])
    end

    # delete
    def self.delete()
        query = "DELETE FROM Profiles WHERE uuid IS ?"
        self.db.execute(query, self.uuid)
    end
end

class Challenge
    
    def initialize(db, uuid)
        self.db = db
        self.uuid = uuid
    end
    
    def self.create(db, username, title, content)
        query = "INSERT INTO Profiles (user_id, uuid, title, content) VALUES (?, ?, ?, ?, ?)"
        uuid = SecureRandom.uuid()
        self.db.execute(query, [username, uuid, title, content])
    end

    # GET info
    def self.all(db)
        query = "SELECT uuid FROM Challenges"
        resp = self.db.execute(query)[]
        p resp
        resp.map! {|uuid| Challenge(self.db, uuid) }
        return resp
    end

    def self.get()
        query = "SELECT user_id, title, content FROM Challenges WHERE uuid IS ?"
        resp = self.db.execute(query, uuid)
        return resp
    end

    def self.get_comments()
        query = "SELECT user_id, content FROM Comments WHERE challenge_id IS ?"
        resp = self.db.execute(query, uuid)
        return resp
    end
    
    # update
    def self.update_content(new_content)
        query = "UPDATE Challenges SET content= ? WHERE uuid IS ?"
        self.db.execute(query, [new_content, uuid])
    end
    def self.update_title(new_title)
        query = "UPDATE Challenges SET title= ? WHERE uuid IS ?"
        self.db.execute(query, [new_title, uuid])
    end

    # delete
    def self.delete()
        query = "DELETE FROM Challenges WHERE uuid IS ?"
        self.db.execute(query, self.uuid)
    end
end

class Comment
    
    def intialize(db, uuid)
        self.db = db
        self.uuid = uuid
    end
    
    def self.create(db, username, challenge_uuid, content)
        query = "INSERT INTO Comments (uuid, user_id, challenge_id, content) VALUES (?, ?, ?, ?)"
        uuid = SecureRandom.uuid()
        self.db.execute(query, [uuid, username, challenge_uuid, content])
    end
    
    def self.create(db, username)
        # create profile
        query = "INSERT INTO Profiles (user_id, uuid, content, img_url) VALUES (?, ?, ?, ?)"
        
        content = ""
        img_url = ""
        self.db.execute(query, [username, uuid, content, img_url])
    end
    
    def self.all(db)
        query = "SELECT uuid FROM Comments"
        resp = self.db.execute(query)[]
        p resp
        resp.map! {|uuid| Challenge.new(self.db, uuid) }
        return resp
    end
    
    # update
    def self.update_content(new_content)
        query = "UPDATE Comments SET content= ? WHERE uuid IS ?"
        self.db.execute(query, [new_content, uuid])
    end
    
    #delete 
    def self.delete()
        query = "DELETE FROM Comments WHERE uuid IS ?"
        self.db.execute(query, self.uuid)
    end
end
