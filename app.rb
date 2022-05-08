require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

@protected_routs = ["/edit", "/my_site", "/new"]

before do 
    if @protected_routs.include?(request.path_info)
        if session[:id] != []
            # Gör inget
        else
            redirect to ("/users/not_inlogg")
        end
    end
end

get("/") do
    slim(:index)
end

get("/fandoms") do
    result = fandoms
    #p result
    slim(:"doors/fandoms",locals:{fandom:result})

end

get ("/register") do
    slim(:register)
end


get ("/error_not_same") do
    slim(:"errors/error_not_same")
end

get ("/error_password") do
    slim(:"errors/error_wrong_password")
end


post ("/users/new") do
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

get ("/login") do 
    slim(:login)
end

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

get ("/logga_ut") do
    session[:id] = []
    slim(:"/users/logga_ut")
end

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

post ("/fandoms/new") do
    Name=params[:Name]
    Id=params[:Id]
    Author=params[:Author]
    Short_name=params[:Short_name]
    #p "Vi fick in datan #{Name}, #{FandomId}, #{Author}, #{CreatorId} och #{Short_name}."
    result = fandoms_new(Name, Id, Author, Short_name)
    p "här är result"
    p result
    redirect("/fandoms")
end

post ('/fandoms/:id/delete') do
    if session[:id] != []
        id = params[:id].to_i
        result = fandoms_delete(id)
        redirect("/fandoms")
    else
        redirect("/not_inlogg")
    end
end


post ('/fandoms/:id/update') do
    if session[:id] != []
        id = params[:id]
        #p "detta är id"
        #p id
        Fandom_name = params[:Fandom_name]
        #p "detta är Fandom name"
        #p Fandom_name
        Author = params[:Author]
        #p "detta är author"
        #p Author
        result = fandoms_update(id, Fandom_name)
        result2 = creator_update(id, Author)
        #p "här är result"
        #p result
        #p "det här är result2"
        #p result2
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

get("/fandoms/:id") do
    id = params[:id].to_i
    result = fandoms_id_part1(id)
    result2 = fandoms_id_part2(id)
    slim(:"doors/show",locals:{result:result, result2:result2})
end

post ("/my_list/:id/delete") do
    UserId = session[:id].to_i
    RelationId = params[:RelationId]
    result = my_list_delete(UserId, RelationId)
    redirect("/my_site")
end