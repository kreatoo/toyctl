# From kreatolinux/src
# Licensed under GPLv3
import std/httpclient
import terminal, math, strutils, os

proc onProgressChanged(total, progress, speed: BiggestInt) =
  stdout.eraseLine
  var p = "Downloaded "&formatSize(progress)
  
  if formatSize(total) != "0B":
    p = p&" of "&formatSize(total)

  p = p&" at "&formatSize(speed)&"/s"

  if $round(int(progress) / int(total)*100) != "inf":
    let percent = parseInt(formatBiggestFloat(round(int(progress) / int(total)*100), precision = -1)) 
    let perc = int(percent / 2)

    stdout.styledWriteLine(formatSize(total), "    ", fgWhite, "[", '-'.repeat (if perc >= 1: perc - 1 else: perc), ">", " ".repeat 50 - perc, "]", if percent > 50: fgGreen else: fgYellow, "    ", $percent , "% at ", formatSize(speed)&"/s")
    if percent != 100:
      cursorUp 1
    eraseLine()
  else:
    stdout.write(p)
    stdout.flushFile

proc download*(client = newHttpClient(), url: string, file: string, instantErrorIfFail = false,
    raiseWhenFail = false) =
  try:
    client.onProgressChanged = onProgressChanged 
    client.downloadFile(url, file&".partial")
    moveFile(file&".partial", file)
    echo ""
  except Exception:
    if instantErrorIfFail:
      if raiseWhenFail or not defined(release):
        raise getCurrentException()
      else:
        echo "error: download failed"
        quit(1)

    echo "warn: download failed, retrying"
    download(client, url, file, true, raiseWhenFail)
