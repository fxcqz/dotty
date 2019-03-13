import htmlparser
import httpclient
from random import rand, randomize
import strformat
import strtabs
import strutils
import xmltree

proc nimBash*(message: cstring): cstring {.exportc.} =
  result = "".cstring
  var client = newHttpClient()
  let
    url: string = &"http://bash.org/?random1"
    response = client.getContent(url)
    html = parseHTML(response)
  var quotes: seq[string] = @[]

  for p in html.findAll("p"):
    if p.attrs["class"] == "qt":
      # this is our quote content
      quotes.add(p.innerText)

  result = quotes.rand.replace("<br>", "\n").cstring
