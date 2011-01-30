require 'rubygems'
require 'mongo'
require 'pp'
include Mongo

db   = Connection.new.db('twitter')
profiles = db.collection('profiles')
friends  = db.collection('friends')

puts "FYI http://api.mongodb.org/ruby/current/file.TUTORIAL.html"

pp "find by limit"
profiles.find().limit(1).each do |prof|
  pp prof
end

pp "find by field"
profiles.find("screen_name" => 'fuba').each do |prof|
  pp prof
end

pp "find by >($gt greater than)"
profiles.find({"listed_count" => {"$gt" => 2000}},
               :fields => ["screen_name", "listed_count"]).limit(10).each do |prof|
  pp prof
end

pp "get following"
fuba_internal_id = profiles.find_one("screen_name" => "fuba")["internal_id"]
fuba_following = friends.find_one("internal_id" => fuba_internal_id)

pp "is shokai followed by fuba?"
shokai_internal_id = profiles.find_one("screen_name" => "shokai")["internal_id"]
pp fuba_following["ids"].include?(shokai_internal_id)

pp "output id csv"
friends.find("internal_id" => fuba_internal_id).each do |me|
  puts me["ids"].map{|id| id.to_s}.join(",")[0,100]
end

pp "output screen_name csv"
friends.find("internal_id" => fuba_internal_id).each do |me|
  result = []
  me["ids"].each do |id|
    prof = profiles.find_one("internal_id" => id)
    if prof != nil
      result << prof["screen_name"]
    else
      result << id.to_s
    end
  end
  puts result.join(",")[0,100]
end

pp "follower (few mintes...)"
#pp friends.find({"ids" => fuba_internal_id}, :fields => ["internal_id"]).map{|follower|}.size

sum = 0
count = 0
unique = {}
begin
  require 'kyotocabinet'
  include KyotoCabinet
  unique = KyotoCabinet::DB::new
  unique.open('/mnt/ssd/casket.kch', KyotoCabinet::DB::OWRITER | KyotoCabinet::DB::OCREATE)
  puts "counting unique node with kyotocabinet"
rescue
  unique = {}
  puts "counting unique node with builtin hash. it takes huge memory...use http://fallabs.com/kyotocabinet/"
end

friends.find().each do |doc|
    next unless doc.include?("ids")
    sum += doc["ids"].size
    count += 1
    puts [count,unique.count] if count % 100000 == 0
    doc.map{|friend| unique[friend] = true}
end
puts "count: #{count}"
puts "edge: #{sum}"
puts "uniq(f): #{unique.count()}"
unique.close
