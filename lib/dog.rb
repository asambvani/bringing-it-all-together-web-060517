class Dog

attr_accessor :name, :breed, :id

  def initialize(info_hash)
    @name = info_hash[:name]
    @breed = info_hash[:breed]
    if info_hash[:id]
      @id = info_hash[:id]
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (
      ?,
      ?
    );
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(info_hash)
    dog = Dog.new(info_hash)
    dog.save
  end

  def self.find_by_id(id)

    sql = <<-SQL
    SELECT * FROM dogs
    WHERE
    id = ?
    SQL
    row = DB[:conn].execute(sql, id).flatten
    Dog.new_from_db(row)

  end

  def self.new_from_db(row)
    info_hash = {:name=> row[1], :breed=> row[2]}
    dog = Dog.new(info_hash)
    dog.id = row[0]
    dog
  end

  def self.find_or_create_by(info_hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE
    name = ?
    AND
    breed = ?
    SQL
    existing_dog = DB[:conn].execute(sql,info_hash[:name],info_hash[:breed]).flatten
    if existing_dog.size>0
      Dog.new_from_db(existing_dog)
    else
      Dog.create(info_hash)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE
    name = ?
    SQL
    Dog.new_from_db(DB[:conn].execute(sql,name).flatten)

  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET
    name = ?,
    breed = ?
    WHERE
    id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    
  end

end
