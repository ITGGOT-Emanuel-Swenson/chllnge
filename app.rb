class CHLLNGE < Sinatra::Base
    db_path = "database/chllnge.db"
    database = DataBase.new(db_path)
    db_handler = DBHandler.new(database.db)
    def authorized(db)
        login_cookie = session[:login]
        username = session[:username]
        
        if login_cookie and username
            return Authentication.cookie_match(db, username, login_cookie)
        end
  
    end
get '' do
    erb :index
end

# restful paths below 

get '/challenges' do 
    # get list of all challenges 
end

get '/challenges/new' do 
    # get template for creating a new challenge 
end

get '/challenges/:uuid' do
    # get a specific challenge
end

post '/challenges/' do
    # create
end

patch '/challenges/:uuid/edit' do
    # edit
end

delete '/challenges/:uuid' do
    # delete
end



get '/profiles' do 
    # get list of all profiles 
end

get '/profiles/new' do 
    # get template for creating a new profile 
end

get '/profiles/:uuid' do
    # get a specific profile
end

post '/profiles/' do
    # create
end

patch '/profiles/:uuid/edit' do
    # edit
end

delete '/profiles/:uuid' do
    # delete
end


get '/comments' do 
    # get list of all comments 
end

get '/comments/new' do 
    erb :index
    # get template for creating a new comment 
end

get '/comments/:uuid' do
    # get a specific comment
end

post '/comments/' do
    # create
end

patch '/comments/:uuid/edit' do
    # edit
end

delete '/comments/:uuid' do
    # delete
end


get '/register' do
    erb :register
end
post '/register' do

end


get '/login' do
    
end
post '/login' do

end


get '/logout' do
    session[:username] = ''
    session[:login_cookie] = ''
    redirect to("/")
end
end
