import std/os
import std/parsecfg
import std/strutils
import std/osproc
import std/logging
import ../modules/run

const hardcoded = "ghcr.io"

proc run*(image: seq[string], command = "sh", runtime = "crun") =
  ## Runs a command with an image.
  let imageSplitted = image[0].split(":")
  var tag = "latest"
  var dir: string
  if imageSplitted.len > 1:
    tag = imageSplitted[1]
  
  if tag == "latest":
    let dict = loadConfig(getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&imageSplitted[0]&"/info.ini")
    dir = getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&imageSplitted[0]&"/"&dict.getSectionValue("Image", "latestImageId")
  #else:
  #  getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&imageSplitted[0]&"/"&
  
  runInternal(imageSplitted[0], tag, dir, runtime, command, lvlAll)
