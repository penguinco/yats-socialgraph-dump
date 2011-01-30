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

##MongoDBのインストール
ubuntu:  
    $ apt-get install mongodb

###MongoDBにダンプを入れる
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

##操作
ruby:
    $ bundle
    $ ruby scripts/tutorial.rb
###find by limit
    profiles.find().limit(1).each do |prof|
      pp prof
    end
> {"_id"=>BSON::ObjectId('4d29b935b69fff50abd3d690'),
> "contributors_enabled"=>false,
> "created_at"=>"Mon Oct 11 13:36:15 +0000 2010",
> "description"=>
>  "Pixiv内企画【絵師学生化】に参加中の橘さよと申します！鍵付きですがお気軽にフォローしてくださると嬉しいです´｀*　さよは「」でつぶやきます。それ以外は中の人です！　どうぞよろしくお願いします！！　※絵師学関係の方のみフォロー・リフォロー致します。ご了承下さい。",
> "favourites_count"=>0,
> "follow_request_sent"=>false,
> "followers_count"=>36,
> "following"=>false,
> "friends_count"=>37,
> "geo_enabled"=>false,
> "id"=>201266053,
> "id_str"=>"201266053",
> "internal_id"=>201266053,
> "is_translator"=>false,
> "lang"=>"ja",
> "listed_count"=>2,
> "location"=>"遊高2-9",
> "name"=>"橘　さよ",
> "notifications"=>false,
> "profile_background_color"=>"1A1B1F",
> "profile_background_image_url"=>
>  "http://a0.twimg.com/profile_background_images/177403026/095_-____.JPG",
> "profile_background_tile"=>true,
> "profile_image_url"=>
>  "http://a1.twimg.com/profile_images/1221894418/___400_normal.jpg",
> "profile_link_color"=>"2FC2EF",
> "profile_sidebar_border_color"=>"181A1E",
> "profile_sidebar_fill_color"=>"252429",
> "profile_text_color"=>"666666",
> "profile_use_background_image"=>true,
> "protected"=>true,
> "screen_name"=>"sayo_tcbn",
> "show_all_inline_media"=>false,
> "statuses_count"=>2865,
> "time_zone"=>"Hawaii",
> "url"=>
>  "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=13466044",
> "utc_offset"=>-36000,
> "verified"=>false}

###find by field
    profiles.find("screen_name" => 'fuba').each do |prof|
      pp prof
    end

> {"_id"=>BSON::ObjectId('4c72cb941d41c8640e00135a'),
> "contributors_enabled"=>false,
> "created_at"=>"Fri Apr 13 00:12:57 +0000 2007",
> "description"=>"XBL:ecceecce, GameCenter:fuba, クレクレ厨",
> "favourites_count"=>3523,
> "follow_request_sent"=>false,
> "followers_count"=>2693,
> "following"=>true,
> "friends_count"=>2629,
> "geo_enabled"=>true,
> "id"=>4426821,
> "id_str"=>"4426821",
> "internal_id"=>4426821,
> "is_translator"=>false,
> "lang"=>"en",
> "listed_count"=>216,
> "location"=>"Cybertron, Aichi, Japan",
> "name"=>"fuba",
> "notifications"=>false,
> "profile_background_color"=>"2e0028",
> "profile_background_image_url"=>
>  "http://a1.twimg.com/profile_background_images/146583845/background_biribiri_by_gaichuu.png",
> "profile_background_tile"=>false,
> "profile_image_url"=>
>  "http://a3.twimg.com/profile_images/1196523326/soundwave_blocknoise_2_70off_normal.jpg",
> "profile_link_color"=>"ff17e8",
> "profile_sidebar_border_color"=>"ff00aa",
> "profile_sidebar_fill_color"=>"45003c",
> "profile_text_color"=>"910091",
> "profile_use_background_image"=>true,
> "protected"=>false,
> "screen_name"=>"fuba",
> "show_all_inline_media"=>false,
> "status"=>
> {"favorited"=>false,
>  "contributors"=>nil,
>  "truncated"=>false,
>  "text"=>"ガラケーで何もする気になれないので寝る",
>  "created_at"=>"Sun Jan 23 18:03:18 +0000 2011",
>  "retweeted"=>false,
>  "in_reply_to_status_id_str"=>nil,
>  "coordinates"=>nil,
>  "id"=>29237755057807360,
>  "source"=>"<a href=\"http://twtr.jp\" rel=\"nofollow\">Keitai Web</a>",
>  "in_reply_to_status_id"=>nil,
>  "place"=>nil,
>  "id_str"=>"29237755057807360",
>  "in_reply_to_screen_name"=>nil,
>  "retweet_count"=>0,
>  "geo"=>nil,
>  "in_reply_to_user_id_str"=>nil,
>  "in_reply_to_user_id"=>nil},
> "statuses_count"=>86358,
> "time_zone"=>"Yakutsk",
> "url"=>"http://give-me-money.g.hatena.ne.jp/fuba/",
> "utc_offset"=>32400,
> "verified"=>false}

###find by >($gt greater than)
    profiles.find({"listed_count" => {"$gt" => 2000}},
                   :fields => ["screen_name", "listed_count"]).limit(10).each do |prof|
      pp prof
    end

> {"_id"=>BSON::ObjectId('4c7254c51d41c831ff00092c'),
> "listed_count"=>2386909,
> "screen_name"=>"ichiyonnana"}
> {"_id"=>BSON::ObjectId('4c7255771d41c831ff0016db'),
> "listed_count"=>4091,
> "screen_name"=>"xFernandaJonas"}
> {"_id"=>BSON::ObjectId('4c7256ba1d41c831ff002fc3'),
> "listed_count"=>2173,
> "screen_name"=>"nufufu"}
> {"_id"=>BSON::ObjectId('4c725a621d41c85ccb001206'),
> "listed_count"=>4588,
> "screen_name"=>"tamukenchaaaaa"}
> {"_id"=>BSON::ObjectId('4c725fd91d41c85ccb0054c6'),
> "listed_count"=>2011,
> "screen_name"=>"CourtneyLoveUK"}
> {"_id"=>BSON::ObjectId('4c7263a31d41c85ccb0081ca'),
> "listed_count"=>8981,
> "screen_name"=>"UNIQLO_JP"}
> {"_id"=>BSON::ObjectId('4c7267bd1d41c85ccb00b166'),
> "listed_count"=>2277,
> "screen_name"=>"Fumybeppu"}
> {"_id"=>BSON::ObjectId('4c726ca91d41c85ccb00ea34'),
> "listed_count"=>3672,
> "screen_name"=>"maruyamakun"}
> {"_id"=>BSON::ObjectId('4c72720d1d41c85ccb01250d'),
> "listed_count"=>3807,
> "screen_name"=>"keiichisokabe"}
> {"_id"=>BSON::ObjectId('4c7273651d41c85ccb0131f0'),
> "listed_count"=>2764,
> "screen_name"=>"weeklyascii"}

###get following
    fuba_internal_id = profiles.find_one("screen_name" => "fuba")["internal_id"]
    fuba_following = friends.find_one("internal_id" => fuba_internal_id)

###is shokai followed by fuba?
    shokai_internal_id = profiles.find_one("screen_name" => "shokai")["internal_id"]
    pp fuba_following["ids"].include?(shokai_internal_id)

> true

###output id csv
    friends.find("internal_id" => fuba_internal_id).each do |me|
      puts me["ids"].map{|id| id.to_s}.join(",")[0,100]
    end

> 164743710,51774619,18574112,6064612,175079593,99697384,101801049,123140561,15210265,180215207,156135

###output screen_name csv
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

> 164743710,51774619,umaiboo,6064612,kanda_daisuke,bolze_doujin,KEUMAYA,Joey__Jones,0mg,ma2omat2,amasa

python:
    $ easy_install pymongo
    $ easy_install netowrkx
    $ python scripts/pagerank.py hotchpotch 

> nodes: 26278 edges: 48631
>            kirino_kousaka pagerank:0.000258156777601
>            kuroneko_daten pagerank:0.00025809348788
>                hotchpotch pagerank:6.01247478341e-05
>                 naoya_ito pagerank:4.97764199926e-05
>                      hmsk pagerank:4.75135120034e-05
>                     cho45 pagerank:4.67476492448e-05
>                   kentaro pagerank:4.67101132016e-05
>                   masason pagerank:4.62623944468e-05
>                  nagayama pagerank:4.61941538602e-05
>                    jkondo pagerank:4.6025069974e-05
>           yasuhiro_onishi pagerank:4.58139861351e-05
>                 ninjinkun pagerank:4.57463639227e-05
>                      toya pagerank:4.56101703846e-05
>                  amachang pagerank:4.52832315871e-05
>                     marqs pagerank:4.50329375441e-05
>                   higepon pagerank:4.47297502099e-05
>                   stanaka pagerank:4.46696009947e-05
>                 bulkneets pagerank:4.45274564057e-05
>            itoi_shigesato pagerank:4.43871531049e-05
>                  yosukeim pagerank:4.43336437358e-05
>                    hakobe pagerank:4.4320095813e-05
>              nandeyanen36 pagerank:4.39290143487e-05
>                  yukawasa pagerank:4.38318952978e-05
>                 tokuhirom pagerank:4.37260257209e-05
>                  takesako pagerank:4.36955343397e-05
>                    negipo pagerank:4.35389456433e-05
>                 164085718 pagerank:4.34082295434e-05
>                 sacco0627 pagerank:4.34023603078e-05
>                   hideoki pagerank:4.33475466644e-05
>                   motemen pagerank:4.32431730034e-05
> hotchpotch.gml was created.



