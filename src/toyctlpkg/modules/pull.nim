import std/logging
import std/httpclient
import std/json
import std/strutils

proc imageDownloader(token: string, domain: string, image: string, logger: ConsoleLogger) =
  # Internal proc to download images, and put them to the right place.
  logger.log(lvlDebug, "imageDownloader ran")


proc pullInternal*(image: string, tag: string, logLevel = lvlAll) =
  # Proc for pulling images.
  const domain = "ghcr.io"
  
  var loggerMain = newConsoleLogger(levelThreshold=logLevel, fmtStr="[$time] - $levelname: ")
  loggerMain.log(lvlDebug, "pullInternal ran, image: '"&image&"' tag: '"&tag&"'")
  var client = newHttpClient()
  
  let token = replace($parseJson(client.getContent("https://"&domain&"/token?scope=repository:"&image&":pull"))["token"], "\"", "")
  
  loggerMain.log(lvlDebug, "Setting token to '"&token&"'")
  client.headers = newHttpHeaders({"Authorization": "Bearer "&token})
  
  let images = parseJson(client.getContent("https://"&domain&"/v2/"&image&"/tags/list"))["tags"]
  
  var tagExists = false

  for i in images:
    if ($i).replace("\"", "") == tag:
      tagExists = true
      loggerMain.log(lvlInfo, "Tag "&tag&" found")
      break
      
  if not tagExists:
    loggerMain.log(lvlFatal, "Tag not found: "&tag)
  else:
    loggerMain.log(lvlInfo, "Beginning pulling")
    imageDownloader(token, domain, image, loggerMain)

  client.close()
  
