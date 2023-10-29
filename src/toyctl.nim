## Tool and library for managing OCI containers
import cligen
import toyctlpkg/commands/pullcmd
import toyctlpkg/commands/runcmd
import toyctlpkg/commands/createcmd
import toyctlpkg/commands/rmcmd
import toyctlpkg/commands/startcmd
import toyctlpkg/commands/stopcmd

when isMainModule:
  dispatchMulti(
  [
    pull
  ],
  [
    run
  ],
  [
    start
  ],
  [
    stop
  ],
  [
    createCommand,
    cmdName="create"    
  ],
  [
    rm
  ]
  )
