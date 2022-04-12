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



post ('/fandoms/:id/update') do
    id = params[:id]
    fandom_name=params[:name]
    creator_name = params[:creator]
    db = SQLite3::Database.new("db/chinook-crud.db")
    db.execute("UPDATE fandom SET Name=? WHERE FandomId=?", fandom_name, id)
    db.execute("UPDATE creator SET Name=? WHERE CreatorId=?", creator_name, id)
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