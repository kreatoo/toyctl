import std/logging

proc runInternal*(image, tag, dir, runtime, command: string, logLevel = lvlAll) =
  # Runs a container with the specified command.
  echo "a"
