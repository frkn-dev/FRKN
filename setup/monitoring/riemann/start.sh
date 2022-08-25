#!/usr/bin/env bash
top="$(dirname "$0")/.."

JAR=${JAR:-$top/lib/riemann.jar:$EXTRA_CLASSPATH}
CONFIG="$top/etc/riemann.config"
COMMAND="start"
AGGRESSIVE_OPTS="-server -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -XX:+UseCompressedOops -XX:+CMSClassUnloadingEnabled"

usage()
{
  cat << EOF
usage: $0 [-a] [java options ...] [command] [config-file]

Runs Riemann with the given configuration file.

OPTIONS:
  -h    Show this message
  -a    Adds some default aggressive, nonportable JVM optimization flags.
  -v    Show version and exit

COMMANDS:
  start    Start the Riemann server (this is the default)
  test     Run the configuration tests

  Any unrecognized options (e.g. -XX:+UseParNewGC) will be passed on to java.
EOF
}

OPTS=
for arg in "$@"; do
  case $arg in
    "-a")
      OPTS="$AGGRESSIVE_OPTS $OPTS"
      ;;
    "-h")
      usage
      exit 0
      ;;
    "-v")
      COMMAND="version"
      CONFIG="show"
      ;;
    -*)
      OPTS="$OPTS $arg"
      ;;
    test|start)
      COMMAND="$arg"
      ;;
    *)
      CONFIG="$arg"
     ;;
  esac
done

echo exec java $EXTRA_JAVA_OPTS $OPTS -cp "$JAR" riemann.bin "$COMMAND" "$CONFIG"
exec java $EXTRA_JAVA_OPTS $OPTS -cp "$JAR" riemann.bin "$COMMAND" "$CONFIG"
