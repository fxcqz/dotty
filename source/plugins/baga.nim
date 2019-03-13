import htmlparser
import httpclient
from random import rand, randomize
import strformat
import strtabs
import strutils
import xmltree

import nimutils


let baseUrl: string = "https://www.holy-bhagavad-gita.org"

proc getQuote(response: string): string =
  let html = parseHTML(response)

  for verse in html.findAll("div"):
    if "id" in verse.attrs:
      if verse.attrs["id"] == "translation":
        return verse.innerText.strip.replace("\n", " ")

  return ""

proc randomQuote(): string =
  let
    chapter = (1..18).rand
    url: string = &"{baseUrl}/chapter/{chapter}"
    response = Client.getContent(url)
    html = parseHTML(response)

  var verses: seq[string] = @[]
  for a in html.findAll("a"):
    if "verse" in a.attrs["href"]:
      verses.add(a.attrs["href"])

  let response2 = Client.getContent(&"{baseUrl}{verses.rand}")
  return getQuote(response2)

proc specificQuote(text: string): string =
  let parts = text.split(".")
  var
    chapter: int
    verse: int

  try:
    chapter = parts[0].parseInt
    verse = parts[1].parseInt
  except ValueError:
    return ""

  try:
    let
      url = &"{baseUrl}/chapter/{chapter}/verse/{verse}"
      response = Client.getContent(url)
    return getQuote(response)
  except:
    return "That's not a real chapter or verse"

proc nimBaga*(message: cstring): cstring {.exportc.} =
  let text = &"{message}" # dumb convert

  if text.len > 0 and "." in text:
    return specificQuote(text).cstring
  else:
    return randomQuote().cstring
