require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      through = self.class.assoc_options[through_name]
      source = through.model_class.assoc_options[source_name]

      through_table = through.table_name 
      through_primary = through.primary_key 
      through_foreign = through.foreign_key 

      source_table = source.table_name 
      source_primary = source.primary_key
      source_foreign = source.foreign_key

      key_val = self.send(through_foreign)
      ans = DBConnection.execute(<<-SQL, key_val)
        SELECT 
          #{source_table}.* 
        FROM 
          #{through_table}
        JOIN 
          #{source_table} 
        ON 
          #{through_table}.#{source_foreign} = #{source_table}.#{source_primary}
        WHERE 
          #{through_table}.#{through_primary} = ? 
      SQL

    source.model_class.parse_all(ans).first
    end 
  end
end
