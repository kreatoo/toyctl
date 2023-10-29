import std/os
import std/times
import std/strutils
import std/parsecfg
import randgen

proc createInternal*(image, tag, runtime, command: string): string =
  # Creates a container and returns the container ID.
  let finalSum = randId()
  let confPath = getHomeDir()&"/.local/share/toyctl/containers.ini"
  createDir(getHomeDir()&"/.local/share/toyctl/containers/created/"&finalSum) 
  createDir(getHomeDir()&"/.local/share/toyctl/containers/created/"&finalSum&"/diff")
  var dict: Config
  
  if fileExists(confPath):
    dict = loadConfig(confPath)
  else:
    dict = newConfig()
  
  let containerIds = dict.getSectionValue("", "containerId")

  if isEmptyOrWhitespace(containerIds):
    dict.setSectionKey("", "containerId", finalSum)
  else:
    dict.setSectionKey("", "containerId", containerIds&" "&finalSum)

  dict.setSectionKey(finalSum, "image", image)
  dict.setSectionKey(finalSum, "command", command)
  dict.setSectionKey(finalSum, "created", $now())
  dict.setSectionKey(finalSum, "status", "Created")
  dict.setSectionKey(finalSum, "ports", "") # TODO
  dict.setSectionKey(finalSum, "names", "") # TODO

  dict.writeConfig(confPath)

  return finalSum

