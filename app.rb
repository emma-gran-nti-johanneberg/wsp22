require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

get("/") do
    slim(:index)
end

get("/fandoms") do

    db = SQLite3::Database.new("db/fandoms.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM fandom")
    #p result
    slim(:"doors/fandoms",locals:{fandom:result})

end

get ("/register") do
    slim(:register)
end

get ("/Error_not_same") do
    slim(:"doors/error_not_same")
end

post ("/users/new") do
    username=params[:username]
    password=params[:password]
    password_confirm=params[:password_confirm]

    if (password==password_confirm)
        # Om de är samma och lyckas
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new("db/fandoms.db")
        db.execute("INSERT INTO user(Username, Password) VALUES(?,?)", username, password_digest)
        redirect("/register")
    else
        # Om det inte är samma och det blir fel
        redirect("/Error_not_same")
    end
end

get ("/fandoms/new") do
    slim(:"doors/new")
end

post ("/fandoms/new") do
    Name=params[:Name]
    FandomId=params[:FandomId]
    Author=params[:Author]
    CreatorId=params[:CreatorId]
    Short_name=params[:Short_name]
    p "Vi fick in datan #{Name}, #{FandomId}, #{Author}, #{CreatorId} och #{Short_name}."
    db = SQLite3::Database.new("db/fandoms.db")
    db.execute("INSERT INTO fandom (Name, FandomId, Short_name) VALUES (?,?,?)", Name, FandomId, Short_name)
    db.execute("INSERT INTO creator (Author, CreatorId) VALUES (?,?)", Author, CreatorId)
    redirect("/fandoms")
end

post ('/fandoms/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/fandoms.db")
    db.execute("DELETE FROM fandom WHERE FandomId=?", id)
    redirect("/fandoms")
end


post ('/fandoms/:id/update') do
    id = params[:id]
    Fandom_name = params[:Fandom_name]
    Author = params[:Author]
    db = SQLite3::Database.new("db/chinook-crud.db")
    db.execute("UPDATE fandom SET Name=? WHERE FandomId=?", Fandom_name, id)
    db.execute("UPDATE creator SET Author=? WHERE CreatorId=?", Author, id)
    redirect('/fandoms')
end


get ('/fandoms/:id/edit') do

    id = params[:id].to_i
    db = SQLite3::Database.new("db/fandoms.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
    result2 = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
    slim(:"/doors/edit", locals:{result:result,result2:result2})

end

get("/fandoms/:id") do
    
    id = params[:id].to_i
    db = SQLite3::Database.new("db/fandoms.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
    result2 = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
    slim(:"doors/show",locals:{result:result,result2:result2})

end