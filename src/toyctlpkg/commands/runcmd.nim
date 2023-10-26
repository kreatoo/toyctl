proc run*(image: seq[string], command = "sh", runtime = "crun") =
  ## Runs a command with an image.
  echo image
  echo command
