import std/logging
import std/httpclient
import std/json
import std/strutils
import std/os
import std/parsecfg
import download
import logger

let imagesPath = getHomeDir()&"/.local/share/toyctl/containers"

proc imageDownloader(client: HttpClient, domain: string, image: string, token: string, logger: Logger) =
  # Internal proc to download images, and put them to the right place.
  logger.log(lvlDebug, "imageDownloader ran")
  createDir(imagesPath)
  let layers = parseJson(client.getContent("https://"&domain&"/v2/"&image&"/manifests/latest"))["layers"]
  
  # Maybe this shouldn't be hardcoded? idk
  client.headers = newHttpHeaders({"Accept": "application/vnd.docker.image.rootfs.diff.tar.gzip", "Authorization": "Bearer "&token})

  var layerConf = newConfig()
  var layerSums: string

  for i in layers:
    # TODO: check if the folder exist, don't download if it does
    # TODO: test with multiple layers
    let sum = ($i["digest"]).replace("\"", "")
    let folderSum = sum.replace(":", "-")
    logger.log(lvlDebug, "Downloading "&folderSum)
    createDir(imagesPath&"/registry/"&domain&"/"&image&"/"&folderSum)
    logger.log(lvlDebug, "https://"&domain&"/v2/"&image&"/blobs/"&sum)
    download(client, "https://"&domain&"/v2/"&image&"/blobs/"&sum, imagesPath&"/registry/"&domain&"/"&image&"/"&folderSum&"/image.tar.gz")
    logger.log(lvlInfo, "Layer "&folderSum&" downloaded")
    setCurrentDir(imagesPath&"/registry/"&domain&"/"&image&"/"&folderSum)
    discard execShellCmd("bsdtar -xf image.tar.gz")
    removeFile("image.tar.gz")

    if isEmptyOrWhitespace(layerSums):
      layerSums = folderSum
    else:
      layerSums = layerSums&" "&folderSum
  
  layerConf.setSectionKey("Image", "containerId", layerSums)
  layerConf.writeConfig(imagesPath&"/registry/"&domain&"/"&image&"/info.ini")

  logger.log(lvlInfo, "All layers downloaded for "&image)

proc pullInternal*(image: string, tag: string, loggerMain = newLogger(lvlAll)) =
  # Proc for pulling images.
  const domain = "ghcr.io"
  
  loggerMain.log(lvlDebug, "pullInternal ran, image: '"&image&"' tag: '"&tag&"'")
  var client = newHttpClient()
  
  var token: string

  try:
    token = replace($parseJson(client.getContent("https://"&domain&"/token?scope=repository:"&image&":pull"))["token"], "\"", "")
  except HttpRequestError:
    loggerMain.log(lvlFatal, "Couldn't get token, image probably doesn't exist")
    return

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
     
    imageDownloader(client, domain, image, token, loggerMain)

  client.close()
  
