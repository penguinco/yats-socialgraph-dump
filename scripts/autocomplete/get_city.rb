# -*- coding: utf-8 -*-
require 'rubygems'
require 'mongo'
include Mongo

MONGOHOST = "192.168.11.13"
NUM_OF_DICT = 2000000 #number of screen_name for autocomplete dictionary

db   = Connection.new(MONGOHOST).db('twitter')
profiles = db.collection('profiles')
friends  = db.collection('friends')

profiles.find().limit(NUM_OF_DICT).each_with_index do |prof, i|
  puts "#{prof["location"] || ""}"
end
