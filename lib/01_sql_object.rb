require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    all_info = DBConnection.execute2(<<-SQL) 
      SELECT 
        *
      FROM 
        #{self.table_name}
    SQL
    column_array = all_info.first.map(&:to_sym)
    @columns = column_array
  end

  def self.finalize!
    self.columns.each do |column| 
      define_method(column) do 
        self.attributes[column]
      end 

      define_method("#{column}=") do |value| 
        self.attributes[column] = value 
      end 

    end 
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    all_rows = DBConnection.execute(<<-SQL)
      SELECT 
        * 
      FROM 
        #{self.table_name}
    SQL

    parse_all(all_rows)
  end

  def self.parse_all(results)
    results.map {|row_hash| self.new(row_hash)}
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id)
      SELECT 
        * 
      FROM 
        #{self.table_name}
      WHERE 
        id = ? 
    SQL
    row.first ? self.new(row.first) : nil 
  end

  def initialize(params = {})
    params.each do |col_name, val|
      col_name = col_name.to_sym 
      if self.class.columns.include?(col_name)
        self.send("#{col_name}=", val)
      else 
        raise "unknown attribute '#{col_name}'"
      end 
    end 
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr| self.send(attr) }
  end

  def insert
    cols = self.class.columns.drop(1)
    col_names = cols.map(&:to_s).join(", ")
    question_marks = (["?"] * cols.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
