import std/strutils
import ../modules/rm

proc rm*(id: seq[string], force = false) =
  ## Removes container and returns its ID. 
  if isEmptyOrWhitespace(id[0]):
    echo "ERROR: please specify an ID"
    quit(1)

  if force:
    # TODO: stopcmd
    echo "Not supported"
    quit(1)

  echo removeInternal(id[0])

