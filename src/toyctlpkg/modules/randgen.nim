import std/sysrand
import checksums/sha2

proc randId*(): string =
  # Random sha256 sum generator.
  var hasher = initSha_256()

  hasher.update($urandom(100))

  return $hasher.digest()
