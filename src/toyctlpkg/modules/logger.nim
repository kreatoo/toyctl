import std/logging

proc newLogger*(logLevel = lvlAll): Logger =
  ## Convenience proc to start a new logger.
  let logger = newConsoleLogger(levelThreshold=logLevel, fmtStr="[$time] - $levelname: ")
  logger.log(lvlInfo, "toyctl - v1.0.0-alpha")
  return logger
