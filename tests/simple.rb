require 'active_record'

class Person < ActiveRecord::Base
  establish_connection :adapter => 'postgresql', :database => 'diaspora_development'
  connection.create_table table_name, :force => true do |t|
    t.string :name
  end
end

bob = Person.create!(:name => 'bob')
puts Person.all.inspect
bob.destroy
puts Person.all.inspect
