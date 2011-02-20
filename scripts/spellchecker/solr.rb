# -*- encoding: utf-8 -*-
require 'rubygems'
require 'rsolr'
require 'mongo'
include Mongo

MONGOHOST = "192.168.11.13"
SOLRPATH  = "http://localhost:8983/solr/core0/"
NUM_OF_DICT = 100 #number of screen_name for spellcheck dictionary

db   = Connection.new(MONGOHOST).db('twitter')
profiles = db.collection('profiles')
friends  = db.collection('friends')

solr = RSolr.connect :url => SOLRPATH

profiles.find().limit(NUM_OF_DICT).each_with_index do |prof, i|
  solr.add :id =>i, :valid_query => prof["screen_name"].downcase
  #puts "#{prof["screen_name"].downcase}"
  if i % 50000 == 0
    solr.commit
  end
end
solr.commit

puts "complete... now we can play with #{NUM_OF_DICT} screen_name on solr."
puts "build spellcheck dictionary..."
response = solr.get "spellCheckCompRH", :params => {
                                            :"spellcheck.build" => false, #should be true for first time
                                            :"spellcheck.q" => "hitode09",
                                            :spellcheck => true
                                            }

response["spellcheck"]["suggestions"].each_with_index do |spell, i|
  if i % 2 == 0
    print "#{spell} => "
  else
    puts "#{spell["suggestion"].inspect}"
  end
end

=begin
$ ruby solr.rb
complete... now we can play with 1080000 screen_name on solr.
build spellcheck dictionary...
  hitode09 => ["hitode909"]
=end
