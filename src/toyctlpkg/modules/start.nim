import std/os
import std/parsecfg
import std/logging
import std/osproc
import std/strutils
#import create
import logger

const hardcoded = "ghcr.io"

proc startInternal*(container: string, runtime: string, logger = newLogger(lvlAll), interactive = true, command = "sh") =
  # Starts a container.
  # container can be an ID or a name.
  logger.log(lvlDebug, "startInternal run, running container '"&container&"' with runtime '"&runtime&"'")
  
  var containerId = container

  # TODO: create if container doesn't exist
  if not dirExists(getHomeDir()&"/.local/share/toyctl/containers/created/"&container):
    logger.log(lvlFatal, "Container has to be a ID for now.")
    quit(1)
    # containerId = createContainer()
  
  let containerPath = getHomeDir()&"/.local/share/toyctl/containers/created/"&container

  let confPath = getHomeDir()&"/.local/share/toyctl/containers.ini"
  var dict: Config

  if fileExists(confPath):
    dict = loadConfig(confPath)
  else:
    logger.log(lvlFatal, "couldn't open containers.ini")
    quit(1)
 
  # TODO: check if container is already started, error out if it is

  # Mount
  logger.log(lvlDebug, "Mounting layers...")
  let containerName = dict.getSectionValue(containerId, "image")
  let commandContainer = dict.getSectionValue(containerId, "command") 
  var dict2: Config

  try:
    dict2 = loadConfig(getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&containerName&"/info.ini")
  except Exception:
    logger.log(lvlFatal, "An error occured while trying to load container information")
    quit(1)
 
  var lowerLayers: string

  for i in dict2.getSectionValue("Image", "containerId").split(" "):
    logger.log(lvlDebug, "Adding "&i&" to layers")
    let layer = getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&containerName&"/"&i
    if isEmptyOrWhitespace(lowerLayers):
      lowerLayers = layer 
    else:
      lowerLayers = lowerLayers&":"&layer

  createDir(containerPath&"/work")
  createDir(containerPath&"/rootfs")
  
  let command = "mount -t overlay overlay -o lowerdir="&lowerLayers&",upperdir="&containerPath&"/diff,workdir="&containerPath&"/work "&containerPath&"/rootfs"

  logger.log(lvlDebug, "Running '"&command&"'")
  
  if execShellCmd(command) != 0:
    logger.log(lvlFatal, "Mounting failed")
    quit(1)
  
  setCurrentDir(containerPath)

  # TODO: do your own spec generator
 

  # Actually, this might not belong here, not sure
  
  #recvtty
  #let createCmdStr = runtime&" create --console-socket tty.sock "&containerId

  #logger.log(lvlDebug, "Executing create command")
  #logger.log(lvlDebug, "CMD: "&createCmdStr)
  #let createCmd = execCmd(createCmdStr)
  #if createCmd.exitCode != 0:
  # logger.log(lvlDebug, createCmd.output)
  # logger.log(lvlFatal, "Creating container failed")
  # quit(1)
  
  # TODO: reflect that its started on containers.ini
  
  logger.log(lvlDebug, "Executing start command")
  var startCmd: int

  # We use run for now as we don't currently need the flexibility create/start gives us.
  if interactive: 
    startCmd = execCmd(runtime&" run "&containerId)
  else:
    startCmd = execCmd(runtime&" run -d "&containerId)

  if startCmd != 0:
    logger.log(lvlFatal, "Starting failed")
    quit(1) 
