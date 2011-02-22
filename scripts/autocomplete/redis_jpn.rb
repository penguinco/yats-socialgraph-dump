# encoding: utf-8
require 'rubygems'
require 'redis'
$KCODE = "UTF8"
require 'moji'
require 'MeCab'
require_relative 'romkan' #ruby is 1.9.2

LIMIT = 12
BLOCK = (LIMIT/5).to_i
FLIMIT = 4
MORE = 10

EXPERIMENT_PORT = 12345
redis = Redis.new(:port => EXPERIMENT_PORT)
mecab = MeCab::Tagger.new

def yomi(mecab,text)
  result = ""
  text = text.gsub(" ", "<SPACE>")
  node = mecab.parseToNode(text)
  while node do
    yomi = node.feature.split(",")[-1]
    if yomi != "*"
      result << yomi
    else
      result << node.surface
    end
    node = node.next
  end
  return result.gsub("<SPACE>", " ")
end

def build(mecab, r, file_path)
  puts "Loading entries in the Redis DB\n"
  line = 0
  File.new("city.csv").each_line{|n|
    line += 1
    if line % 1000 == 0
      puts line
      puts n
    end
    surface = n.strip.gsub("　", " ").gsub(/ +/, " ")
    key_strokes = []
    key_strokes << Moji.kata_to_hira(surface.encode!('UTF-8', 'UTF-8', :undef => :replace)).to_roma.downcase
    key_strokes << Moji.kata_to_hira(yomi(mecab, surface).encode!('UTF-8', 'UTF-8', :undef => :replace)).to_roma.downcase
    key_strokes.each do |key_stroke|
      c = 1
      (1..(key_stroke.length)).each{|l|
        prefix = key_stroke[0...l]
        r.zadd(:compl,0,prefix)
        if prefix.size <= FLIMIT
          r.zincrby(prefix,1,key_stroke[prefix.size, key_stroke.size]) #if you load incrementaly, prefer zincrby()
          if rand(10) == 0
            suf_size = r.zrange(prefix,0,-1).size
            if suf_size >= LIMIT
              r.zremrangebyrank(prefix, 0, suf_size-LIMIT+1)
            end
          end
        end
      }
      r.zadd(:compl,0,key_stroke+"\t")
      r.zincrby(:count,1,key_stroke)
      r.zadd("__surface*#{key_stroke}",1,surface)
      if rand(10) == 0
        sur_size = r.zrange("__surface*#{key_stroke}", 0, -1).size
        if sur_size > 2
          r.zremrangebyrank("__surface*#{key_stroke}", 0, sur_size/2)
        end
      end
    end
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
  range = r.zrevrange(prefix, 0, count)
  range.each {|entry|
    results << prefix + entry
  }
  return results
end

def complete(r,prefix,count)
  prefix = Moji.kata_to_hira(prefix).gsub("-", "ー")
  top = complete_top(r,prefix,count)
  if top.size <= count
    puts "oops"
    return (top + complete_tail(r,prefix,count)).uniq.map{|v|r.zrevrange("__surface*#{v}",0,0)}
  else
    return top.map{|v|r.zrevrange("__surface*#{v}",0,0)}
  end
end

if ARGV.size == 1
  puts complete(redis, ARGV[0].to_roma.downcase, 5)
else
  build(mecab, redis, "city.csv")
end
