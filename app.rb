require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

include Model # Wat dis?

@protected_routs = ["/fandoms/:id/edit", "/my_site", "/fandoms/new"]

before do 
    if @protected_routs.include?(request.path_info)
        if session[:id] != []
            # Gör inget
        else
            redirect to ("/users/not_inlogg")
        end
    else
        #Visa
    end
end

# Display Landing Page
#
get("/") do
    slim(:index)
end

get("/fandoms") do
    result = fandoms
    #p result
    slim(:"doors/fandoms",locals:{fandom:result})

end

# Displays a register form
#
get ("/register") do
    slim(:register)
end

# Displays an error message
#
get ("/error_not_same") do
    slim(:"errors/error_not_same")
end

# Displays an error message
#
get ("/error_password") do
    slim(:"errors/error_wrong_password")
end


# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
# @param [String] repeat-password, The repeated password
#
# @see Model#password_confirming
post ("/users") do
    username=params[:username]
    password=params[:password]
    password_confirm=params[:password_confirm]

    if (password==password_confirm)
        # Om de är samma och lyckas
        result = password_confirming(username, password, password_confirm)
        redirect("/register")
    else
        # Om det inte är samma och det blir fel
        redirect("/error_not_same")
    end

end

# Displays a login form
#
get ("/login") do 
    slim(:login)
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
#
# @see Model#login
post ("/login") do
    username=params[:username]
    password=params[:password]

    result = login(username, password)
    pwdigest = result["Password"]
    id = result["UserId"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect("/my_site")
    else
        redirect("error_password")
    end
end

# Displays an logged out message
#
get ("/logga_ut") do
    session[:id] = []
    slim(:"/users/logga_ut")
end

# Displays an error message
#
get ("/not_inlogg") do 
    slim(:"/users/not_inlogg")
end

get ("/my_site") do
    id = session[:id].to_i
    #p id   
    get_id = my_site(id)
    get_fandoms = my_list(id)
    slim(:"/users/my_site", locals:{fandom1:get_id, fandom2:get_fandoms})
end


post ("/user_access") do
    id = session[:id].to_i
    user_access=params[:user_access]
    db = SQLite3::Database.new("db/fandoms.db")
    db.results_as_hash = true
    hej = db.execute("SELECT AccessID FROM access WHERE AccessID IN (SELECT access FROM user WHERE UserId = ?)", id )
    
    redirect("/my_site")
end


get ("/fandoms/new") do
    slim(:"doors/new")
end

# Creates a new fandom and redirects to '/fandoms'
#
# @param [String] name, The Name of the fandom
# @param [Integer] id, The Id of the fandom & author
# @param [string] author, The Author of the fandom
# @param [string] short_name, The Short_name of the fandom
#
# @see Model#fandom_new
post ("/fandoms") do
    name=params[:name]
    id=params[:id]
    author=params[:author]
    short_name=params[:short_name]
    #p "Vi fick in datan #{Name}, #{FandomId}, #{Author}, #{CreatorId} och #{Short_name}."
    result = fandoms_new(name, id, author, short_name)
    p "här är result"
    p result
    redirect("/fandoms")
end

# Deletes an existing article and redirects to '/fandoms'
#
# @param [Integer] :id, The ID of the fandom
#
# @see Model#fandoms_delete
post ('/fandoms/:id/delete') do
    if session[:id] != []
        id = params[:id].to_i
        result = fandoms_delete(id)
        redirect("/fandoms")
    else
        redirect("/not_inlogg")
    end
end


# Updates an existing article and redirects to '/fandoms'
#
# @param [Integer] :id, The ID of the fandom
# @param [String] fandom_name, The new Fandom_name of the fandom
# @param [String] author, The new Author of the article
#
# @see Model#fandoms_update
# @see Model#creator_update
post ('/fandoms/:id/update') do
    if session[:id] != []
        id = params[:id]
        fandom_name = params[:Fandom_name]
        author = params[:Author]
        result = fandoms_update(id, fandom_name)
        result2 = creator_update(id, author)
        redirect('/fandoms')
    else 
        redirect("/not_inlogg")
    end
end

post ('/fandoms/:id/join') do 
    if session[:id] != []
        id = params[:id].to_i
        UserId = session[:id].to_i
        result = fandoms_join(id, UserId)
        redirect("/fandoms")
    else
        redirect("/not_inlogg")
    end
end

get ('/fandoms/:id/edit') do
    if session[:id] != []
        id = params[:id].to_i
        result = fandoms_edit_part1(id)
        result2 = fandoms_edit_part2(id)
        slim(:"/doors/edit", locals:{result:result, result2:result2})
    else
        slim(:"/users/not_inlogg")
    end
end

# Displays a single Article
#
# @param [Integer] :id, the ID of the article
# @see Model#fandoms_id_part1
# @see Model#fandoms_id_part2
get("/fandoms/:id") do
    id = params[:id].to_i
    result = fandoms_id_part1(id)
    result2 = fandoms_id_part2(id)
    slim(:"doors/show",locals:{result:result, result2:result2})
end

post ("/my_list/:id/delete") do
    id = session[:id].to_i
    relationid = params[:relationid]
    result = my_list_delete(id, relationid)
    redirect("/my_site")
end