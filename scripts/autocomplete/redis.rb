require 'rubygems'
require 'redis'

LIMIT = 10
BLOCK = (LIMIT/5).to_i
FLIMIT = 4
MORE = 20

r = Redis.new

need_update = false
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
      r.zadd(:compl,0,prefix)
      if prefix.size <= FLIMIT
        #r.zincrby(prefix,1,n[prefix.size, n.size]) #if you load incrementaly, prefer zincrby()
        r.zadd(prefix,c.to_i,n[prefix.size, n.size])
        count = r.incr("*count*#{prefix}")
        if count > LIMIT
          newcount = count - r.zremrangebyrank(prefix, 0, count-LIMIT+BLOCK)
          r.set("*count*#{prefix}", newcount)
        end
      end
    }
    r.zadd(:compl,0,n+"*")
    r.zadd(:count,c.to_i,n)
  }
end

# Complete the string "mar"

def complete_tail(r,prefix,count)
    results = []
    _count = count*MORE
    rangelen = 50 # This is not random, try to get replies < MTU size
    start = r.zrank(:compl,prefix)
    return [] if !start
    while results.length != _count
        range = r.zrange(:compl,start,start+rangelen-1)
        start += rangelen
        break if !range or range.length == 0
        range.each {|entry|
            minlen = [entry.length,prefix.length].min
            if entry[0...minlen] != prefix[0...minlen]
                _count = results.count
                break
            end
            if entry[-1..-1] == "*" and results.length != _count
                results << [entry[0...-1], r.zscore(:count, entry[0...-1])]
            end
        }
    end
    return results.sort{|a, b| a[1].to_i <=> b[1].to_i}.reverse[0,count].map{|v|v[0]}
end

def complete_top(r,prefix,count)
  results = []
  #return []
  range = r.zrevrange(prefix, 0, count)
  range.each {|entry|
    results << prefix + entry[0...-1]
  }
  return results
end

def complete(r,prefix,count)
  top = complete_top(r,prefix,count)
  if top.size <= count
    return (top + complete_tail(r,prefix,count-top.size)).uniq
  else
    return top
  end
end

10.times do |t|
  puts complete(r,"pengu",5).inspect
end
10.times do |t|
  puts complete(r,"fu",10).inspect
end
