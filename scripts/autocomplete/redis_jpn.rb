# -*- coding: utf-8 -*-
require 'rubygems'
require 'redis'
$KCODE = "u"
require 'moji'
require 'MeCab'
require_relative 'Romkan' #ruby is 1.8.7

LIMIT = 12
BLOCK = (LIMIT/5).to_i
FLIMIT = 4
MORE = 10

r = Redis.new
m = MeCab::Tagger.new()
m.parseToNode("日本語")

return 0
def yomi(text)
  result = ""
  node = MeCab::Tagger.new.parseToNode(text)
  while node do
    yomi = node.feature.split(",")[-1]
    if yomi != "*"
      result << yomi
    else
      result << node.surface
    end
    node = node.next
  end
  return result
end

need_update = true
# Create the completion sorted set
if need_update
  puts "Loading entries in the Redis DB\n"
  line = 0
  File.new("city.csv").each_line{|n|
    line += 1
    if line % 1000 == 0
      puts line
      puts n
    end
    n_surface = n.strip.gsub("　", " ")
    n = Moji.kata_to_hira(yomi(n_surface)).to_roma
    c = 1
    (1..(n.length)).each{|l|
      prefix = n[0...l]
      r.zadd(:compl,0,prefix)
      if prefix.size <= FLIMIT
        r.zincrby(prefix,1,n[prefix.size, n.size]) #if you load incrementaly, prefer zincrby()
        count = r.incr("__count*#{prefix}")
        if count > LIMIT
          newcount = count - r.zremrangebyrank(prefix, 0, count-LIMIT+BLOCK)
          r.set("__count*#{prefix}", newcount)
        end
      end
    }
    r.zadd(:compl,0,n+"\t")
    r.zincrby(:count,1,n)
    r.zadd("__surface*#{n}",1,n_surface)
  }
end

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
                _count = results.size
                break
            end
            if entry[-1..-1] == "\t" and results.length != _count
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
  prefix = Moji.kata_to_hira(prefix)
  top = complete_top(r,prefix,count)
  if top.size <= count
    return (top + complete_tail(r,prefix,count-top.size)).uniq.map{|v|r.zrevrange("__surface*#{v}",0,0)}
  else
    return top.map{|v|r.zrevrange("__surface*#{v}",0,0)}
  end
end

puts complete(r,"s",10)
puts "----"
puts complete(r,"さ".to_roma,10)
puts "----"
puts complete(r,"あず".to_roma,10)
puts "----"
puts complete(r,"nyan",10)
puts "----"
