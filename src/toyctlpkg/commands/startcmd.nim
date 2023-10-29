import ../modules/start

proc start*(containers: seq[string]) =
  ## Start one (or more) containers. Container ID or the name can be used.
  for container in containers:
    startInternal(container)
