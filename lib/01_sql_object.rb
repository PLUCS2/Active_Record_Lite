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
      

    end 
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    # debugger
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes ||= {}

  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
