# Package

version       = "0.1.0"
author        = "Kreato"
description   = "Tool and library for managing OCI containers"
license       = "GPL-2.0-only"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["toyctl"]


# Dependencies

requires "cligen >= 1.6.15"
requires "nim >= 2.0.0"
