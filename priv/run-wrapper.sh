#!/usr/bin/env bash

# See: https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes

# Start the program in the background
exec "$@" &
pid1=$!

# The docker client needs to be killed with the right signal for it to tell
# the docker daemon to kill the container as well.
trap "kill -1 $pid1" SIGINT SIGKILL EXIT

# Silence warnings from here on
exec >/dev/null 2>&1

# Read from stdin in the background and
# kill running program when stdin closes
exec 0<&0 $(
  while read; do :; done
  kill -1 $pid1
) &
pid2=$!

# Clean up
wait $pid1
ret=$?
kill -KILL $pid2
exit $ret
