#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
cat part-*.b64 | tr -d '\n' | base64 -d > ../ensaio-s-correcao-visita2-nosecrets.tgz
ls -lh ../ensaio-s-correcao-visita2-nosecrets.tgz
cd ..
tar -xzf ensaio-s-correcao-visita2-nosecrets.tgz
test -f Dockerfile
test -f templates/index.html
grep -q 'Checar se está no ar' templates/index.html
bash deploy-visita2-image-only.sh
