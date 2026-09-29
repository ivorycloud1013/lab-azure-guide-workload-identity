#!/usr/bin/env bash
# SA 명의의 Google ID token 을 발급받아 주요 claim 을 출력한다. (서명 검증 없음 — 디버깅 용도)
# 사용법: scripts/decode-jwt.sh <SA ID> <project ID>
#   project ID 는 SA 가 있는 project. gcloud CLI 자격 증명(gcloud auth login)으로 impersonate 한다.
set -euo pipefail

usage="사용법: scripts/decode-jwt.sh <SA ID> <project ID>"
sa_id="${1:?${usage}}"
project="${2:?${usage}}"
sa_email="${sa_id}@${project}.iam.gserviceaccount.com"

token="$(gcloud auth print-identity-token --impersonate-service-account="${sa_email}" \
  --audiences=api://AzureADTokenExchange --include-email 2>/dev/null)" \
  || { echo "ERROR: ${sa_email} 의 ID token 발급 실패 (project ID, Token Creator 권한 확인)" >&2; exit 1; }

payload="$(cut -d. -f2 <<<"${token}" | tr '_-' '/+')"
# base64url padding 보정
case $(( ${#payload} % 4 )) in
  2) payload="${payload}==" ;;
  3) payload="${payload}=" ;;
esac

base64 --decode <<<"${payload}" | jq '{iss, sub, aud, email, iat: (.iat | todate), exp: (.exp | todate)}'
