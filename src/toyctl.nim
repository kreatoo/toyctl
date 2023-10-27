## Tool and library for managing OCI containers
import cligen
import toyctlpkg/commands/pullcmd
import toyctlpkg/commands/runcmd

when isMainModule:
  dispatchMulti(
  [
    pull
  ],
  [
    create
  ],
  [
    run
  ]
  )
