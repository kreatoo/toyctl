import std/os
import std/strutils
import std/parsecfg

proc removeInternal*(id: string): string =
  # Removes the container and returns the deleted ID.
  
  let confPath = getHomeDir()&"/.local/share/toyctl/containers.ini"
  
  if not fileExists(confPath):
    echo "ERROR: no containers exist"
    quit(1)
  
  var dict = loadConfig(confPath)
  
  var containerIds = dict.getSectionValue("", "containerId").split(" ")

  if not (id in containerIds):
    echo "ERROR: container doesn't exist"
    quit(1)
  
  if dict.getSectionValue(id, "status").toLower == "running":
    echo "ERROR: container is still running"
    quit(1)

  dict.delSection(id)

  containerIds.delete(containerIds.find(id))

  dict.setSectionKey("", "containerId", containerIds.join(" "))
    
  dict.writeConfig(confPath)

  removeDir(getHomeDir()&"/.local/share/toyctl/containers/created/"&id)

  return id
