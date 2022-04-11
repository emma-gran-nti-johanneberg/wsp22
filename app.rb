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

get ('/fandoms/:id/edit') do
    
    id = params[:id].to_i
    db = SQLite3::Database.new("db/fandoms.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
    result2 = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
    slim(:"/doors/edit", locals:{result:result,})

end

get("/fandoms/:id") do
    
    id = params[:id].to_i
    db = SQLite3::Database.new("db/fandoms.db")
    db.results_as_hash=true
    result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
    result2 = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
    slim(:"doors/show",locals:{result:result,result2:result2})

end