# coding: utf-8
#
# Ruby/Romkan - a Romaji <-> Kana conversion library for Ruby.
#
# Copyright (C) 2001 Satoru Takabayashi <satoru@namazu.org>
#     All rights reserved.
#     This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms of 
# the Ruby's licence.
#
# NOTE: Ruby/Romkan can work only with EUC_JP encoding. ($KCODE="e")
#

module Romkan
  VERSION = '0.4'
end

class Array
  def pairs(s=2)
    0.step(self.size-1,s){
      |x| yield self.slice(x,s)
    }
  end
end
  
class String
# This table is imported from KAKASI <http://kakasi.namazu.org/> and modified.
  KUNREITAB = "\
ぁ  xa  あ  a ぃ  xi  い  i ぅ  xu
う  u う゛  vu  う゛ぁ  va  う゛ぃ  vi  う゛ぇ  ve
う゛ぉ  vo  ぇ  xe  え  e ぉ  xo  お  o 

か  ka  が  ga  き  ki  きゃ  kya きゅ  kyu 
きょ  kyo ぎ  gi  ぎゃ  gya ぎゅ  gyu ぎょ  gyo 
く  ku  ぐ  gu  け  ke  げ  ge  こ  ko
ご  go 

さ  sa  ざ  za  し  si  しゃ  sya しゅ  syu 
しょ  syo じ  zi  じゃ  zya じゅ  zyu じょ  zyo 
す  su  ず  zu  せ  se  ぜ  ze  そ  so
ぞ  zo 

た  ta  だ  da  ち  ti  ちゃ  tya ちゅ  tyu 
ちょ  tyo ぢ  di  ぢゃ  dya ぢゅ  dyu ぢょ  dyo 

っ  xtu 
っう゛  vvu っう゛ぁ  vva っう゛ぃ  vvi 
っう゛ぇ  vve っう゛ぉ  vvo 
っか  kka っが  gga っき  kki っきゃ  kkya 
っきゅ  kkyu  っきょ  kkyo  っぎ  ggi っぎゃ  ggya 
っぎゅ  ggyu  っぎょ  ggyo  っく  kku っぐ  ggu 
っけ  kke っげ  gge っこ  kko っご  ggo っさ  ssa 
っざ  zza っし  ssi っしゃ  ssya 
っしゅ  ssyu  っしょ  ssho 
っじ  zzi っじゃ  zzya  っじゅ  zzyu  っじょ  zzyo 
っす  ssu っず  zzu っせ  sse っぜ  zze っそ  sso 
っぞ  zzo った  tta っだ  dda っち  tti 
っちゃ  ttya  っちゅ  ttyu  っちょ  ttyo  っぢ  ddi 
っぢゃ  ddya  っぢゅ  ddyu  っぢょ  ddyo  っつ  ttu 
っづ  ddu って  tte っで  dde っと  tto っど  ddo 
っは  hha っば  bba っぱ  ppa っひ  hhi 
っひゃ  hhya  っひゅ  hhyu  っひょ  hhyo  っび  bbi 
っびゃ  bbya  っびゅ  bbyu  っびょ  bbyo  っぴ  ppi 
っぴゃ  ppya  っぴゅ  ppyu  っぴょ  ppyo  っふ  hhu 
っふぁ  ffa っふぃ  ffi っふぇ  ffe っふぉ  ffo 
っぶ  bbu っぷ  ppu っへ  hhe っべ  bbe っぺ    ppe
っほ  hho っぼ  bbo っぽ  ppo っや  yya っゆ  yyu 
っよ  yyo っら  rra っり  rri っりゃ  rrya 
っりゅ  rryu  っりょ  rryo  っる  rru っれ  rre 
っろ  rro 

つ  tu  づ  du  て  te  で  de  と  to
ど  do 

な  na  に  ni  にゃ  nya にゅ  nyu にょ  nyo 
ぬ  nu  ね  ne  の  no 

は  ha  ば  ba  ぱ  pa  ひ  hi  ひゃ  hya 
ひゅ  hyu ひょ  hyo び  bi  びゃ  bya びゅ  byu 
びょ  byo ぴ  pi  ぴゃ  pya ぴゅ  pyu ぴょ  pyo 
ふ  hu  ふぁ  fa  ふぃ  fi  ふぇ  fe  ふぉ  fo 
ぶ  bu  ぷ  pu  へ  he  べ  be  ぺ  pe
ほ  ho  ぼ  bo  ぽ  po 

ま  ma  み  mi  みゃ  mya みゅ  myu みょ  myo 
む  mu  め  me  も  mo 

ゃ  xya や  ya  ゅ  xyu ゆ  yu  ょ  xyo
よ  yo

ら  ra  り  ri  りゃ  rya りゅ  ryu りょ  ryo 
る  ru  れ  re  ろ  ro 

ゎ  xwa わ  wa  ゐ  wi  ゑ  we
を  wo  ん  n 

ん     n'
でぃ   dyi
ー     -
ちぇ    tye
っちぇ  ttye
じぇ  zye
"

  HEPBURNTAB = "\
ぁ  xa  あ  a ぃ  xi  い  i ぅ  xu
う  u う゛  vu  う゛ぁ  va  う゛ぃ  vi  う゛ぇ  ve
う゛ぉ  vo  ぇ  xe  え  e ぉ  xo  お  o
  

か  ka  が  ga  き  ki  きゃ  kya きゅ  kyu
きょ  kyo ぎ  gi  ぎゃ  gya ぎゅ  gyu ぎょ  gyo
く  ku  ぐ  gu  け  ke  げ  ge  こ  ko
ご  go  

さ  sa  ざ  za  し  shi しゃ  sha しゅ  shu
しょ  sho じ  ji  じゃ  ja  じゅ  ju  じょ  jo
す  su  ず  zu  せ  se  ぜ  ze  そ  so
ぞ  zo

た  ta  だ  da  ち  chi ちゃ  cha ちゅ  chu
ちょ  cho ぢ  di  ぢゃ  dya ぢゅ  dyu ぢょ  dyo

っ  xtsu  
っう゛  vvu っう゛ぁ  vva っう゛ぃ  vvi 
っう゛ぇ  vve っう゛ぉ  vvo 
っか  kka っが  gga っき  kki っきゃ  kkya  
っきゅ  kkyu  っきょ  kkyo  っぎ  ggi っぎゃ  ggya  
っぎゅ  ggyu  っぎょ  ggyo  っく  kku っぐ  ggu 
っけ  kke っげ  gge っこ  kko っご  ggo っさ  ssa
っざ  zza っし  sshi  っしゃ  ssha  
っしゅ  sshu  っしょ  ssho  
っじ  jji っじゃ  jja っじゅ  jju っじょ  jjo 
っす  ssu っず  zzu っせ  sse っぜ  zze っそ  sso
っぞ  zzo った  tta っだ  dda っち  cchi  
っちゃ  ccha  っちゅ  cchu  っちょ  ccho  っぢ  ddi 
っぢゃ  ddya  っぢゅ  ddyu  っぢょ  ddyo  っつ  ttsu  
っづ  ddu って  tte っで  dde っと  tto っど  ddo
っは  hha っば  bba っぱ  ppa っひ  hhi 
っひゃ  hhya  っひゅ  hhyu  っひょ  hhyo  っび  bbi 
っびゃ  bbya  っびゅ  bbyu  っびょ  bbyo  っぴ  ppi 
っぴゃ  ppya  っぴゅ  ppyu  っぴょ  ppyo  っふ  ffu 
っふぁ  ffa っふぃ  ffi っふぇ  ffe っふぉ  ffo 
っぶ  bbu っぷ  ppu っへ  hhe っべ  bbe っぺ  ppe
っほ  hho っぼ  bbo っぽ  ppo っや  yya っゆ  yyu
っよ  yyo っら  rra っり  rri っりゃ  rrya  
っりゅ  rryu  っりょ  rryo  っる  rru っれ  rre 
っろ  rro 

つ  tsu づ  du  て  te  で  de  と  to
ど  do  

な  na  に  ni  にゃ  nya にゅ  nyu にょ  nyo
ぬ  nu  ね  ne  の  no  

は  ha  ば  ba  ぱ  pa  ひ  hi  ひゃ  hya
ひゅ  hyu ひょ  hyo び  bi  びゃ  bya びゅ  byu
びょ  byo ぴ  pi  ぴゃ  pya ぴゅ  pyu ぴょ  pyo
ふ  fu  ふぁ  fa  ふぃ  fi  ふぇ  fe  ふぉ  fo
ぶ  bu  ぷ  pu  へ  he  べ  be  ぺ  pe
ほ  ho  ぼ  bo  ぽ  po  

ま  ma  み  mi  みゃ  mya みゅ  myu みょ  myo
む  mu  め  me  も  mo

ゃ  xya や  ya  ゅ  xyu ゆ  yu  ょ  xyo
よ  yo  

ら  ra  り  ri  りゃ  rya りゅ  ryu りょ  ryo
る  ru  れ  re  ろ  ro  

ゎ  xwa わ  wa  ゐ  wi  ゑ  we
を  wo  ん  n 

ん     n'
でぃ   dyi
ー     -
ちぇ    che
っちぇ  cche
じぇ  je
"

  KANROM = (kanaroma = Hash.new
      (KUNREITAB + HEPBURNTAB).split(/\s+/).pairs {|x|
        kana, roma = x
        kanaroma[kana] = roma
      }
      kanaroma)

  ROMKAN = (romakana = Hash.new
      (KUNREITAB + HEPBURNTAB).split(/\s+/).pairs {|x|
        kana, roma = x
        romakana[roma] = kana
      }
      romakana)

  # Sort in long order so that a longer Romaji sequence precedes.
  ROMPAT = ROMKAN.keys.sort {|a, b| b.length <=> a.length}.join "|"

  KANPAT = KANROM.keys.sort {|a, b| 
    b.length <=> a.length ||
      KANROM[a].length <=> KANROM[b].length
  }.join "|"

  KUNREI  = (i = 0; KUNREITAB. split(/\s+/).select {i += 1; i % 2 == 0})
  HEPBURN = (i = 0; HEPBURNTAB.split(/\s+/).select {i += 1; i % 2 == 0})

  KUNPAT = KUNREI.sort  {|a, b| b.length <=> a.length }.join "|"
  HEPPAT = HEPBURN.sort {|a, b| b.length <=> a.length }.join "|"

  TO_HEPBURN = (romrom = Hash.new
    KUNREI.each_with_index {|x, i|
      romrom[KUNREI[i]] = HEPBURN[i]}
    romrom)

  TO_KUNREI =  (romrom = Hash.new
    HEPBURN.each_with_index {|x, i|
      romrom[HEPBURN[i]] = KUNREI[i]}
    romrom)

  # FIXME: ad hod solution
  # tanni   => tan'i
  # kannji  => kanji
  # hannnou => han'nou
  # hannnya => han'nya
  def normalize_double_n
    self.gsub(/nn/, "n'").gsub(/n\'(?=[^aiueoyn]|$)/, "n")
  end

  def normalize_double_n!
    self.gsub!(/nn/, "n'")
    self.gsub!(/n\'(?=[^aiueoyn]|$)/, "n")
    self
  end


  # Romaji -> Kana
  # It can handle both Hepburn and Kunrei sequences.
  def to_kana 
    tmp = self.normalize_double_n
    tmp.gsub(/(#{ROMPAT})/) { ROMKAN[$1] }
  end

  # Kana -> Romaji.  
  # Return Hepburn sequences.
  def to_roma
    tmp = self.gsub(/(#{KANPAT})/) {|match| KANROM[match] }
    tmp.gsub!(/n'(?=[^aeiuoyn]|$)/, "n")
    tmp.gsub(/(.)-/) {case $~[1] when "o" then "ou" when "e" then "ei" else $~[1] + $~[1] end} 
  end

  # Romaji -> Romaji
  # Normalize into Hepburn sequences.
  # e.g. kannzi -> kanji, tiezo -> chiezo
  def to_hepburn
    tmp = self.normalize_double_n
    tmp.gsub(/\G((?:#{HEPPAT})*?)(#{KUNPAT})/) { $1 + TO_HEPBURN[$2]}
  end

  # Romaji -> Romaji
  # Normalize into Kunrei sequences.
  # e.g. kanji -> kanzi, chiezo -> tiezo
  def to_kunrei
    tmp = self.normalize_double_n
    tmp.gsub(/\G((?:#{KUNPAT})*?)(#{HEPPAT})/) { $1 + TO_KUNREI[$2]}
  end

  def to_kana!
    self.normalize_double_n!
    self.gsub!(/(#{ROMPAT})/) { ROMKAN[$1] }
    self
  end

  def to_roma!
    self.gsub!(/(#{KANPAT})/) { KANROM[$1] }
    self.gsub!(/n'(?=[^aeiuoyn]|$)/, "n")
    self
  end

  def to_hepburn!
    self.normalize_double_n!
    self.gsub!(/\G((?:#{HEPPAT})*?)(#{KUNPAT})/) { $1 + TO_HEPBURN[$2]}
    self
  end

  def to_kunrei!
    tmp = self.normalize_double_n!
    tmp.gsub!(/\G((?:#{KUNPAT})*?)(#{HEPPAT})/) { $1 + TO_KUNREI[$2]}
  end

  def consonant?
    if /^[ckgszjtdhfpbmyrwxn]$/.match(self)
      true
    else
      false
    end
  end

  def vowel?
    if /^[aeiou]$/.match(self)
      true
    else
      false
    end
  end

  # `z' => (za ze zi zo zu)
  def expand_consonant 
    ROMKAN.keys.select do |x|
      /^#{self}.$/ =~ x 
    end
  end
end

