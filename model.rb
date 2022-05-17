require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

module Model

    # A function that checks that if the input is empyt or not
    def is_it_empty(user_input)
        if user_input.empty?
            return true
        end 
    end

    # A function to link with the database fandoms
    def get_db()
        db = SQLite3::Database.new("db/fandoms.db")
        db.results_as_hash = true
        return db
    end

    # Finds all fandoms
    #
    # @return [Hash]
    #   * FandomId [Integer] The ID of the fandom
    #   * Name [String] The Name of the fandom
    #   * Short_name [String] The short_name of the fandom
    def fandoms()
        db = get_db()
        result = db.execute("SELECT * FROM fandom")
        return result
    end

    # Attempts to create a new user
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    # @option params [String] password_confirm The confirm password
    #
    # @return [Hash]
    #   * :user_id [Integer] The user's ID if the user was created
    def password_confirming(username, password, password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = get_db()
        result = db.execute("INSERT INTO user(Username, Password) VALUES(?,?)", username, password_digest)
        return result
    end

    # Trys to logg in 
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    #
    # @return [Integer] The ID of the user and The access of the user
    def login(username, password)
        db = get_db()
        result = db.execute("SELECT * FROM user WHERE Username = ?", username).first
        return result
    end

    # Collects data from user
    #
    # @param [Hash] params form data
    # @option param [Integer] id The Userid
    #
    # @return [Array] with all data conected to the User
    def my_site(id) 
        db = get_db()
        result = db.execute("SELECT * FROM user WHERE UserId = ?", id).first
        return result
    end

    # Collects data from fandom though innner join of user_fandom_rel where it matches with UserId
    #
    # @params [Hash] params from data
    # @option param [Integer] Id, The Userid
    #
    # @return [Array] with all matching data from fandom
    def my_list(id)
        db = get_db()
        get_fandoms = db.execute("SELECT *
            FROM user_fandom_rel 
            INNER JOIN fandom ON user_fandom_rel.FandomId=fandom.FandomId
            WHERE UserId=?", id)
        return get_fandoms
    end

    # Attempts to find the access of the user
    #
    # @params [Hash] params from data
    # @option param [Integer] Id, The Userid
    # 
    # @return [Integer] the number that stands from the access
    def access(id)
        db=get_db()
        get_access = db.execute("SELECT AccessID FROM access WHERE AccessID IN (SELECT access FROM user WHERE UserId = ?)", id )
        return get_access
    end

    # Attempts to insert a new row in the fandom table
    #
    # @param [Hash] params form data
    # @option params [String] Name, The name of the fandom
    # @option params [String] Short_name, The short name of the fandom
    #
    # @return [Hash]
    #   * result [String] the fandom name and short name
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


    # Attempts to delete a row from the fandom table
    #
    # @param [Integer] id The fandom's ID
    # @param [Hash] params form data
    def fandoms_delete(id)
        db = get_db()
        result = db.execute("DELETE FROM fandom WHERE FandomId=?", id)
        return result
    end

    # Attempts to update a row in the fandom table
    #
    # @param [Integer] id The fandoms's ID
    # @param [Hash] params form data
    # @option params [String] fandom_name The name of the fandom
    #
    # @return [String] the new fandom name
    def fandoms_update(id, fandom_name)
        db = get_db()
        result = db.execute("UPDATE fandom SET Name=? WHERE FandomId=?", fandom_name, id)
        #p "Detta är result för fandoms_update"
        #p result
        return result
    end

    # Attempts to update a row in the creator table
    #
    # @param [Integer] id The author's ID
    # @param [Hash] params form data
    # @option params [String] author The name of the author
    #
    # @return [String] the new author's name
    def creator_update(id, author)
        db = get_db()
        result = db.execute("UPDATE creator SET Author=? WHERE CreatorId=?", author, id)
        #p "Detta är result från creator_update"
        #p result
        return result
    end

    # Attempts to insert user in fandom
    #
    # @param [Hash] params form data
    # @option params [String] UserId The users ID
    # @option params [String] Id The ID of the fandom
    def fandoms_join(id, userid)
        db = get_db()
        result = db.execute("INSERT INTO user_fandom_rel (UserId, FandomId) VALUES (?, ?)", UserId, id)
        return result
    end

    # Finds a fandom
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the fandom
    #
    # @return [Hash]
    #   * :FandomId [Integer] The ID of the fandom
    #   * :Fandom_name [String] The name of the fandom
    def fandoms_edit_part1(id)
        db = get_db()
        result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
        return result
    end

    # Finds a creator
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the creator
    #
    # @return [Hash]
    #   * :CreatorId [Integer] The ID of the creator
    #   * :Author [String] The name of the creator
    def fandoms_edit_part2(id)
        db = get_db()
        result = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
        return result
    end

    # Finds a fandom
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the fandom
    #
    # @return [Hash]
    #   * :FandomId [Integer] The ID of the fandom
    #   * :Fandom_name [String] The name of the fandom
    #   * :Short_name [String] The short name of the fandom
    def fandoms_id_part1(id)
        db = get_db()
        result = db.execute("SELECT * FROM fandom WHERE FandomId=?", id).first
        return result
    end

    # Finds a creator
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the creator
    #
    # @return [Hash]
    #   * :CreatorId [Integer] The ID of the creator
    #   * :Author [String] The name of the creator
    def fandoms_id_part2(id)
        db = get_db()
        result = db.execute("SELECT * FROM creator WHERE CreatorId=?", id).first
        return result
    end

    # Attempts to delete a row from the relationId table
    #
    # @param [Integer] relationid The relation ID between fandom and user
    # @param [Hash] params form data
    def my_list_delete(userid, relationid)
        db = get_db()
        result = db.execute("DELETE FROM user_fandom_rel WHERE RelationId=?", relationid)
        return result
    end
end