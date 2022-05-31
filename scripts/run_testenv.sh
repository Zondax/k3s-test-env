#!/usr/bin/env bash

set -e

echo "==> Running test environment..."

source $(dirname $0)/var_testenv.sh

cleanup()
{
    $(dirname $0)/cleanup_testenv.sh
}
trap cleanup EXIT TERM

source $(dirname $0)/start_k3s.sh

kubectl get all -A
# EXECUTE TESTS