import ../modules/stop

proc stop*(containers: seq[string]) =
  ## Stop one (or more) containers.
  for container in containers:
    stopInternal(container)
