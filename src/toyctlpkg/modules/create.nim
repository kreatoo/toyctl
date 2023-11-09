import std/os
import std/times
import std/osproc
import std/logging
import std/strutils
import std/parsecfg
import randgen
import logger

proc createInternal*(image, tag, runtime, command: string, interactive = true, logger = newLogger()): string =
  # Creates a container and returns the container ID.
  let finalSum = randId()
  let confPath = getHomeDir()&"/.local/share/toyctl/containers.ini"
  let containerPath = getHomeDir()&"/.local/share/toyctl/containers/created/"&finalSum
  createDir(containerPath)
  createDir(containerPath&"/diff")
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
  
  setCurrentDir(containerPath)

  let specCmd = execCmdEx(runtime&" spec")
  if specCmd.exitCode != 0:
   logger.log(lvlDebug, specCmd.output)
   logger.log(lvlFatal, "Generating spec failed")
   quit(1)
  
  return finalSum

