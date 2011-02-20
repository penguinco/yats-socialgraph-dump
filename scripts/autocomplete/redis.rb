require 'rubygems'
require 'redis'

LIMIT = 50
BLOCK = (LIMIT/5).to_i

r = Redis.new

need_update = true 
# Create the completion sorted set
if need_update
  puts "Loading entries in the Redis DB\n"
  line = 0
  File.new("screenname_followercount.csv").each_line{|n|
    line += 1
    if line % 1000 == 0
      puts line
    end
    n,c = n.split(" ")
    (1..(n.length)).each{|l|
      prefix = n[0...l]
      #r.zincrby(prefix,1,n) #if you load incrementaly, prefer zincrby()
      r.zadd(prefix,c.to_i,n)
      count = r.incr("*count*#{prefix}")
      if count > LIMIT
        newcount = count - r.zremrangebyrank(prefix, 0, count-LIMIT+BLOCK)
        r.set("*count*#{prefix}", newcount)
      end
    }
  }
end

def complete(r,prefix,count)
  results = []
  range = r.zrevrangebyscore(prefix, 99999999, 0)[0,count]
  range.each {|entry|
    results << entry[0...-1]
  }
  return results
end

complete(r,"f",10).each{|res|
  puts res
}
puts ""
complete(r,"fu",10).each{|res|
  puts res
}
puts ""
complete(r,"fub",10).each{|res|
  puts res
}
puts ""
complete(r,"fuba",10).each{|res|
  puts res
}

