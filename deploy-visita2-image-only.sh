#!/usr/bin/env bash
set -euo pipefail
RG=rg-conforce-ota
ACR=acrconforceota
APP=ensaio-s-correcao
TAG=correcao-20260922-visita2
IMG="${ACR}.azurecr.io/ensaio-s:${TAG}"
echo "USING RG=$RG ACR=$ACR APP=$APP IMG=$IMG"
test -f Dockerfile
test -f templates/index.html
grep -q 'Checar se está no ar' templates/index.html
grep -q 'Fora do ar' templates/index.html
echo "=== ACR build ==="
az acr build -t "ensaio-s:${TAG}" -g "$RG" -r "$ACR" .
echo "=== CA update IMAGE ONLY (env/secrets preserved) ==="
az containerapp update -n "$APP" -g "$RG" --image "$IMG" \
  -o json --query "{name:name,image:properties.template.containers[0].image,fqdn:properties.configuration.ingress.fqdn,running:properties.runningStatus}"
FQDN=$(az containerapp show -n "$APP" -g "$RG" --query properties.configuration.ingress.fqdn -o tsv)
URL="https://${FQDN}"
echo "URL=$URL"
sleep 35
curl -sS -o /tmp/v2_home.body -w "home:%{http_code}\n" "$URL/" || true
python3 - <<'PY'
from pathlib import Path
home=Path("/tmp/v2_home.body").read_text(errors="replace")
for needle in ("Checar se está no ar","Fora do ar","Ponto quente","Cancelar OK","gateChecklist"):
    print("html", needle, "OK" if needle in home else "MISSING")
print("SMOKE_DONE")
PY
echo "DONE TAG=$TAG URL=$URL"
