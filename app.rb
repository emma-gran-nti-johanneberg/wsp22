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
    p result
    slim(:"doors/fandoms",locals:{fandoms:result})

end