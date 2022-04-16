require 'sinatra'
require 'slim'
require 'sqlite3'

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

get ("/fandoms/new") do
    slim(:"doors/new")
end

post ("/fandoms/new") do
    Name=[:Name]
    FandomId=[:FandomId]
    Author=[:Author]
    CreatorId=[:CreatorId]
    Short_name=[:Short_name]
    p "Vi fick in datan #{Name}, #{FandomId}, #{Author}, #{CreatorId} och #{Short_name}."
    db = SQLite3::Database.new("db/fandoms.db")
    db.execute("INSERT INTO fandom (Name, FandomId, Short_name) VALUES (?,?,?)", Name, FandomId, Short_name)
    db.execute("INSERT INTO creator (Author, CreatorId) VALUES (?,?)", Author, CreatorId)
    redirect("/fandoms")
end

post ('/fandoms/:id/delete') do
    id=params[:id].to_i
    db = SQLite3::Database.new("db/fandoms.db")
    db.execute("DELETE FROM fandom WHERE FandomId=?", id)
    slim(:fandoms)
end


post ('/fandoms/:id/update') do
    id = params[:id]
    Fandom_name=params[:Fandom_name]
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
    db.results_as_hash=true
    result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
    result2 = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
    slim(:"doors/show",locals:{result:result,result2:result2})

end