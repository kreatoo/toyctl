import std/strutils
import std/logging
import ../modules/pull
import ../modules/logger

proc pull*(images: seq[string]) =
  ## Pulls an image from a registry.
  for image in images:
    let imageSplitted = image.split(":")
    var tag = "latest"
    if imageSplitted.len > 1:
      tag = imageSplitted[1]
    
    when not defined(release):
      pullInternal(imageSplitted[0], tag)
    else:
      pullInternal(imageSplitted[0], tag, newLogger(lvlInfo))
