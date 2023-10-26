import cligen
import toyctlpkg/commands/pullcmd
import toyctlpkg/commands/runcmd

when isMainModule:
  dispatchMulti(
  [
    pull
  ],
  [
    run
  ]
  )
