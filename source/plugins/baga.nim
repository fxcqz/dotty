import htmlparser
import httpclient
from random import rand, randomize
import strformat
import strtabs
import strutils
import xmltree

proc nimBaga*(message: cstring): cstring {.exportc.} =
  randomize()
  var client = newHttpClient()
  let
    chapter = (1..18).rand
    baseUrl: string = "https://www.holy-bhagavad-gita.org"
    url: string = &"{baseUrl}/chapter/{chapter}"
    response = client.getContent(url)
    html = parseHTML(response)

  var verses: seq[string] = @[]
  for a in html.findAll("a"):
    if "verse" in a.attrs["href"]:
      verses.add(a.attrs["href"])

  let
    response2 = client.getContent(&"{baseUrl}{verses.rand}")
    html2 = parseHTML(response2)

  for verse in html2.findAll("div"):
    if "id" in verse.attrs:
      if verse.attrs["id"] == "translation":
        return verse.innerText.strip.replace("\n", " ").cstring
