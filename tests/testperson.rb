
require 'uri'
#require File.join(Rails.root, 'lib/hcard')
require 'roxml'
require 'profile'
require 'person'

require 'rubygems'
require 'active_record'
account = "h4ck3rm1k@joindiaspora.com"
#person = Person.by_account_identifier(account)
profile= Profile.new()
person = Person.new()

person.serialized_public_key ( "blah")

if person
  print person
  if person.profile
    print ("event=webfinger status=success route=local target=#{@account}")
    print person
  end
  
end
