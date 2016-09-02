#!/bin/sh
dir="$(dirname $0)"
( echo "called CNI plugin $0" >&2 ; env >&2 ; tee /dev/stderr | "${dir}/real-$(basename ${0})" )
