class Repo

    def initialize(db, table, domain_object, columns, identifier_column, foreign_domain_objects=nil )
        @db = db
        @table = table
        @domain_object = domain_object
        @columns = columns
        @id_column = identifier_column
        if foreign_domain_objects
            @foreign_domain_objects = foreign_domain_objects
        end
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
                
        return get(val_hash[@id_column])
    end
  
    # get domain object
    def get(id)
        begin
            return @domain_object.new(
                                  @db, 
                                  @table, 
                                  @columns, 
                                  @id_column, 
                                  id, 
                                  foreign_domain_objects=@foreign_domain_objects
                                 )
        rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
            return nil
        end
    end
    # get all domain objects
    def all()
        query = "SELECT #{@id_column} FROM #{@table}"
        resp = @db.execute(query)
        resp.flatten!
        resp.map! {|id| get(id)}
        return resp
    end

    def search(column, value)
        # perform a SELECT WHERE query 
        
        # verify that the hash doesnt contain any columns not included in @columns
        if [column] - @columns != []
            raise "Error, invalid column. column: #{column}, value:#{value}\n valid columns:#{@columns}"
        end
        query = "SELECT #{@id_column} FROM #{@table} WHERE #{column} IS ?"
        resp = @db.execute(query, [value]).flatten
        resp.map! {|id| get(id)}
        return resp
    end
   
end

class DomainObject

    def initialize(db, table, columns, identifier_column, id, foreign_domain_objects=nil)
        @db = db
        @table = table
        @columns = columns
        @id_column = identifier_column
        
        if foreign_domain_objects
            @foreign_domain_objects = foreign_domain_objects
        end

        # veryify that the id is valid
        # @get the first column, if it isnt an empty array the id is valid
        @id = id
        p @id
        p @columns.first

        if get(@columns.first) == nil
            raise "Error: invalid id. no data at #{@columns.first}"
        end
    end

    def method_missing(method, *args)
        # conv symbol to string
        method_string = method.to_s
        # split into parts to find out what it supposed to do
        # first part is function and the other is the column
        # ex: 'get_username' => ['get', 'username']
        puts method_string
        method_parts = method_string.split("_")
        puts method_parts
        column = method_parts.slice(1, method_parts.length)
        puts column
        column = column.join('_')
        puts column
        # if the method is longer or equal to 2 and the column in the method name is in the DataObject columns       
        # proceed
        # if not, call the original method_missing
        if method_parts.length >= 2 and @columns.include?(column) 

            # find the operation and pass the column as argument 
            if method_parts[0] == "get"
                # return get(method_parts[1])
                # depreceated, doesnt work if method parts contain additional _
                return get(column)

            elsif method_parts[0] == "set"
                # self.set() requires one more argument, the first value in args 
                return set(column, args[0])

            else
                super(method, *args)
            end
        else
            super(method, *args)
        end
        
    end
    
    # get column
    def get(column)
        # get value from column
        query = "SELECT #{column} FROM #{@table} WHERE #{@id_column} IS ?"
        p query
        resp = @db.execute(query, @id).flatten[0]
        return resp
    end

    def set(column, value)
        # set columns value
        query = "UPDATE #{@table} SET #{column} = ? WHERE #{@id_column} IS ?"
        @db.execute(query, [value, @id]).flatten

    end
    
    def delete()
        # delete column
        # only use for foreign key relationships
        query = "DELETE FROM #{@table} WHERE #{@id_column} IS ?"
        @db.execute(query, [@id])
    end
end
