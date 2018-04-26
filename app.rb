class CHLLNGE < Sinatra::Base
    db_path = "database/chllnge.db"
    db_handler = DBHandler.new(db_path)
    auth = db_handler.auth
   
    comments = db_handler.comments
    challenges = db_handler.challenges
    profiles = db_handler.profiles

before do
    # check if id is valid authorization
    @user_is_authorized = auth.user_authorized(session[:id])
end

get '' do
    slim :index
end


# restful paths below 

get '/challenges' do 
    # get list of all challenges 
    slim :challenges
end
get '/challenges/new' do
    # get input template
    if not @user_is_authorized
        slim :new_challenge
    else
        redirect to("/login")
    end
end

get '/challenges/:uuid' do
    # get a specific challenge
    @challenge = challenges.get(params['uuid'])
    slim :challenge
end

post '/challenges' do 
    # create new challenge
    if @user_is_authorized
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

patch '/challenges/:uuid/edit' do
end

delete '/challenges/:uuid' do
end


get '/profiles' do 
    # get list of all profiles 
    slim :profiles
end

get '/profiles/new' do
end

get '/profiles/:uuid' do
    # get a specific profile
    @profile = profiles.get(params['uuid'])
    slim :profile
end

post '/profiles/' do
    # create
    if @user_is_authorized
        uuid = SecureRandom.uuid
        dict = {
        'user_id' => session[:id],
        'uuid' => uuid,
        'title' => params['title'],
        'content' => params['content'],
        'creation_date' => Time.now.to_s,
        }
        profiles.create(dict)
        redirect to("/profiles/#{uuid}")
    else
        slim :no_permission
    end
end

get '/profiles/:uuid/edit' do
    @profile = profiles.get(params['uuid'])
    if session[:id] == @profile.get_user_id
        slim :edit_profile
    else
        slim :no_permission
    end
end
patch '/profiles/:uuid/edit' do
    @profile = profiles.get(params['uuid'])
    # edit
    if session[:id] == @profile.get_user_id
        slim :edit_profile
    else
        slim :no_permission
    end
end

delete '/profiles/:uuid' do
end


get '/comments' do 
end

get '/comments/:uuid' do
end

post '/comments/' do
    # create
    if @user_is_authorized
        uuid = SecureRandom.uuid
        dict = {
        'user_id' => session[:id],
        'uuid' => uuid,
        'challenge_id' => params['challenge_id'],
        'content' => params['content'],
        'creation_date' => Time.now.to_s,
        }
        comments.create(dict)
        redirect to("/comments/#{uuid}")
    else
        redirect to("/login")
    end
end

patch '/comments/:uuid/edit' do
end

delete '/comments/:uuid' do
end


get '/register' do
    slim :register
end
post '/register' do
    if not @user_is_authorized
        username = params['username']
        password = params['password']
        # sanitize
        if not auth.user_exists(username)
            auth.create_user(username, password)
            
            # create profile
            dict = {
            'user_id' => username,
            'uuid' => SecureRandom.uuid,
            'content' => "",
            'img_url' => "",
            'creation_date' => Time.now.to_s,
            }
            profiles.create(dict)

            session[:id] = username
            redirect to("/")
        end
    else
        slim :logged_in
    end
end


get '/login' do
    if not @user_is_authorized
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
