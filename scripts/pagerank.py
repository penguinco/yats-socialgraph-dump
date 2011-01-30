# -*- encoding: utf-8 -*-
import sys
import networkx as nx

from pymongo.connection import Connection
mngconn = Connection('localhost', 27017)
mngdb = mngconn.twitter
friends = mngdb.friends
profiles = mngdb.profiles

screen_names = {}

def getScreeName(id):
  if id in screen_names: return screen_names[id]
  try:
    screen_names[id] = profiles.find_one({"internal_id": id})["screen_name"]
  except:
    screen_names[id]  =str(id)
  return screen_names[id]

def calc_pagerank(entrypoint="fuba"):
  G=nx.DiGraph()
  for me in friends.find({"internal_id" : profiles.find_one({"screen_name" : entrypoint})["internal_id"]}).limit(1):
    if not "ids" in me: continue
    for friend in me["ids"][:2000]:
      G.add_edge(getScreeName(me["internal_id"]), getScreeName(friend))
      try:
        for friend2 in friends.find_one({"internal_id":friend})["ids"][:300]:
          G.add_edge(getScreeName(friend), getScreeName(friend2))
      except: pass

  print "nodes: %s edges: %s" % (len(G.nodes()), len(G.edges()))
  pagerank = nx.pagerank(G)
  for k, v in sorted(pagerank.items(), key=lambda x:x[1], reverse=True)[:30]:
    print "%25s pagerank:%s" % (k, v)
  nx.write_gml(G,"%s.gml" % entrypoint)
  print "%s.gml was created." % entrypoint 

if __name__ == '__main__':
  entrypoint = sys.argv[1]
  calc_pagerank(entrypoint)  
