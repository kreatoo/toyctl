import std/os
import std/strutils
import std/parsecfg
import ../modules/create

proc createCommand*(image: seq[string], runtime = "crun", command = "sh") =
  ## Creates a container. Returns the created container ID.
  if image.len == 0:
    echo "ERROR: Please specify the image."
    quit(1)

  const hardcoded = "ghcr.io"
  let imageSplitted = image[0].split(":")
  var tag = "latest"
  if imageSplitted.len > 1:
    tag = imageSplitted[1]
 
  let d = getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&imageSplitted[0]

  if not dirExists(d):
    # TODO: autodownload if it doesn't exist
    echo "ERROR: container doesn't exist"
    quit(1)

  echo createInternal(imageSplitted[0], tag, runtime, command)
