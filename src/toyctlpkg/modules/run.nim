import std/logging
import logger

proc runInternal*(image, tag, dir, runtime, command: string, logger = newLogger(lvlAll)) =
  # Runs a container with the specified command.
  echo "a"
