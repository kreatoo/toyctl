proc create*(image: string, runtime = "crun", command = "sh") =
  ## Creates a container. Returns the created container ID.
  for image in images:
    let imageSplitted = image.split(":")
    var tag = "latest"
    var dir: string
    if imageSplitted.len > 1:
      tag = imageSplitted[1]
 
    if tag == "latest":
      let dict = loadConfig(getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&imageSplitted[0]&"/info.ini")
      dir = getHomeDir()&"/.local/share/toyctl/containers/registry/"&hardcoded&"/"&imageSplitted[0]&"/"&dict.getSectionValue("Image", "latestImageId")

    echo createInternal(imageSplitted[0], tag, runtime, dir, command)
