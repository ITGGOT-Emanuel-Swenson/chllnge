class CHLLNGE < Sinatra::Base
    db_path = "database/chllnge.db"
    db_handler = DBHandler.new(db_path)
    auth = db_handler.auth
   
    comments = db_handler.comments
    challenges = db_handler.challenges
    profiles = db_handler.profiles
    def user_is_authorized(db)
        login_cookie = session[:login]
        username = session[:username]
        
        if login_cookie and username
            return auth.cookie_match(db, username, login_cookie)
        end
    end

    auth.verify_user_session([:id])

get '' do
    slim :index
end

# restful paths below 

get '/challenges' do 
    # get list of all challenges 
end

post '/challenges/new' do 
    # get template for creating a new challenge 
    if not auth.user_authorized(session[:id])
        uuid = SecureRandom.uuid
        dict = {
        'user_id' => session[:id],
        'uuid' => uuid,
        'title' => params['title'],
        'content' => params['content'],
        'creation_date' => Time.now.to_s,
        }
        challenges.create(dict)
        redirect to("/challenges/#{uuid}")
    else
    end
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
    slim :register
end
post '/register' do
    if not auth.user_authorized(session[:id])
        username = params['username']
        password = params['password']
        # sanitize
        if not auth.user_exists(username)
            auth.create_user(username, password)
            session[:id] = username
            redirect to("/")
        end
    else
        slim :register_logged_in
    end
end


get '/login' do
    if not auth.user_authorized(session[:id])
        slim :login
    else
        slim :logged_in
    end
end
post '/login' do
    username_input = params['username'] 
    password_input = params['password'] 
    # user exists
    if auth.user_exists(username_input)
        # check if username and password matches
        if auth.login_check(username_input, password_input)
            # succesfull login
            session[:id] = username_input
            redirect to("/")
        else
            slim :login_error
        end
    else
        slim :login_error
    end
end


get '/logout' do
    session.clear
    session[:id] = ''
    redirect to("/")
end
end
