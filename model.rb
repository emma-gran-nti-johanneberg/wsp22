require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

module Model

    def get_db()
        db = SQLite3::Database.new("db/fandoms.db")
        db.results_as_hash = true
        return db
    end

    def fandoms()
        db = get_db()
        result = db.execute("SELECT * FROM fandom")
        return result
    end

    def password_confirming(username, password, password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = get_db()
        result = db.execute("INSERT INTO user(Username, Password) VALUES(?,?)", username, password_digest)
        return result
    end

    def login(username, password)
        db = get_db()
        result = db.execute("SELECT * FROM user WHERE Username = ?", username).first
        return result
    end

    def my_site(id) 
        db = get_db()
        result = db.execute("SELECT * FROM user WHERE UserId = ?", id).first
        return result
    end

    def my_list(id)
        db = get_db()
        get_fandoms = db.execute("SELECT *
            FROM user_fandom_rel 
            INNER JOIN fandom ON user_fandom_rel.FandomId=fandom.FandomId
            WHERE UserId=?", id)
        return get_fandoms
    end

    # Attempts to insert a new row in the fandom table
    #
    # @param [Hash] params form data
    # @params [String] Name, The name of the fandom
    # @params [String] Short_name, The short name of the fandom
    #
    # @return [Hash]
    #   * result [String] the fandom name and short name
    #   * result2 [String] the author name
    def fandoms_new_part1(name, id, short_name)
        db = get_db()
        result = db.execute("INSERT INTO fandom (Name, FandomId, Short_name) VALUES (?,?,?)", name, id, short_name)
        return result
    end

    # Attempts to insert a new row in the creator table
    #
    # @param [Hash] params form data
    # @params [String] Author, The author of the fandom
    #
    # @return [Hash]
    #   * result [String] the authors name and ID
    def fandoms_new_part2(id, author)
        db = get_db()
        result =  db.execute("INSERT INTO creator (Author, CreatorId) VALUES (?,?)", author, id)
        return result
    end


    def fandoms_delete(id)
        db = get_db()
        result = db.execute("DELETE FROM fandom WHERE FandomId=?", id)
        return result
    end

    def fandoms_update(id, fandom_name)
        db = get_db()
        result = db.execute("UPDATE fandom SET Name=? WHERE FandomId=?", fandom_name, id)
        p "Detta är result för fandoms_update"
        p result
        return result
    end

    def creator_update(id, author)
        db = get_db()
        result = db.execute("UPDATE creator SET Author=? WHERE CreatorId=?", author, id)
        p "Detta är result från creator_update"
        p result
        return result
    end

    def fandoms_join(id, userid)
        db = get_db()
        result = db.execute("INSERT INTO user_fandom_rel (UserId, FandomId) VALUES (?, ?)", UserId, id)
        return result
    end

    def fandoms_edit_part1(id)
        db = get_db()
        result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
        return result
    end

    def fandoms_edit_part2(id)
        db = get_db()
        result = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
        return result
    end

    def fandoms_id_part1(id)
        db = get_db()
        result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
        return result
    end

    def fandoms_id_part2(id)
        db = get_db()
        result = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
        return result
    end

    def my_list_delete(userid, relationid)
        db = get_db()
        result = db.execute("DELETE FROM user_fandom_rel WHERE RelationId=?", relationid)
        return result
    end
end