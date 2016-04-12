require 'sqlite3'
require 'csv'

class ReleaseDatabase
  FILE_PATH = 'source/20160406-record-collection.csv'

  attr_reader :db

  def initialize(dbname = "releases")
    @db = SQLite3::Database.new "database/#{dbname}.db"
  end

  def setup!
    reset_schema!
    load!
  end

  private

  def reset_schema!
    puts "Recreating Schema..."

    # table name: albums
    # label_code,artist,title,label,format,released,date_added
    # BLOB, TEXT, TEXT, TEXT, TEXT,        INTEGER,     TEXT
    # one table
    query = <<-CREATESTATEMENT
      CREATE TABLE albums (
        id INTEGER PRIMARY KEY,
        label_code BLOB,
        artist TEXT NOT NULL,
        title TEXT NOT NULL,
        label TEXT,
        format TEXT,
        released INTEGER,
        date_added TEXT
      );
    CREATESTATEMENT

    db.execute("DROP TABLE IF EXISTS albums;")
    db.execute(query) #runs one and only one query!
  end

  def load!
    puts "Preparing INSERT statements..."

    insert_statement = <<-INSERTSTATEMENT
      INSERT INTO albums (
        label_code, artist, title, label, format, released, date_added
      ) VALUES (
        :label_code, :artist, :title, :label, :format, :released, :date_added
      );
    INSERTSTATEMENT

    prepared_statement = db.prepare(insert_statement)

    # now that we have a prepared statement...
    # let's iterate the csv and use its values to populate our database
    CSV.foreach(FILE_PATH, headers: true) do |row|
      prepared_statement.execute(row.to_h)
    end

    puts "Data import complete!"
  end
end

ReleaseDatabase.new.setup!
