#yats socialgraph dump

twitter日本語ユーザー100万人のフォローイングとプロフィールです。  
レコメンデーションの実験や分析に使えるかもしれません。  

##内容
streaming apiから日本語を含み、過去に400つぶやき以上、過去3週間以内に発言のユーザーを収集しました。  
プロフィール情報、フォローイング情報を見ることが出来ます。  

###プロフィールの内容
  約108万人分  
フォローイングの中には英語のユーザーやprotectedのユーザーが含まれます。  
ただし、それらのユーザーのプロフィールは収集されていません。  

###ソーシャルグラフの内容
  約300万ノード / 約2.8億エッジ  
内訳は以下の条件になります。 
    u  = 日本語アクティブユーザー
    u2 = 日本語ではない OR 活発ではない OR api_error
    => = following
    データに入っているもの
      u => u
      u => u2
    入っていないもの
      u2 => u
      u2 => u2

##取得
  http://
##操作
ruby:
    $ bundle
    $ ruby scripts/tutorial.rb
python:
    $ easy_install pymongo
    $ easy_install netowrkx
    $ python scripts/pagerank.py kzk_mover

##MongoDBのインストール
ubuntu:  
    $ apt-get install mongodb

MongoDBにダンプを入れる
以下のコマンドで生成したMongoDB(1.6.5) dumpをMongoDBに読み込みます。
    $ mongodump --db twitter -v
    DATABASE: twitter        to     dump/twitter
          twitter.system.indexes to dump/twitter/system.indexes.bson
          twitter.friends to dump/twitter/friends.bson
          twitter.profiles to dump/twitter/profiles.bson

    $ wget http://api.yats-data.com/data/socialgraph/yats.graph.ja.20110130.tar.gz
    $ tar xzvf yats.graph.ja.20110130.tar.gz
    $ ls dump
    # 以下の操作の前にチェックしてください http://www.mongodb.org/display/DOCS/Import+Export+Tools
    $ mongorestore -d twitter dump/twitter/
    $ mongo
    # how to use : http://www.mongodb.org/display/DOCS/Manual 
     use twitter
     db.friends.stats()                          
    {
	"ns" : "twitter.friends",
	"count" : 1035491,
	"size" : 3412631332,
	"avgObjSize" : 3295.6648894099512,
	"storageSize" : 3882193408,
	"numExtents" : 28,
	"nindexes" : 2,
	"lastExtentSize" : 681069568,
	"paddingFactor" : 1.0099999999880804,
	"flags" : 0,
	"totalIndexSize" : 90062848,
	"indexSizes" : {
		"_id_" : 46170112,
		"internal_id_1" : 43892736
	},
	"ok" : 1
    }
     db.profiles.stats()
    {
	"ns" : "twitter.profiles",
	"count" : 1088040,
	"size" : 2900683092,
	"avgObjSize" : 2665.971004742473,
	"storageSize" : 3809510400,
	"numExtents" : 28,
	"nindexes" : 3,
	"lastExtentSize" : 681069568,
	"paddingFactor" : 1.4099999999730883,
	"flags" : 1,
	"totalIndexSize" : 148996448,
	"indexSizes" : {
		"_id_" : 45359104,
		"internal_id_1" : 46981472,
		"screen_name_1" : 56655872
	},
	"ok" : 1
    }
