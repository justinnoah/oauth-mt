import "lib/codec/percent" =~ [=> PercentEncoding]

import "http/client" =~ [=> makeRequest :DeepFrozen]

exports (main)

def main(argv) as DeepFrozen:
    "oauth"

    traceln("Hello <oauth>!")
