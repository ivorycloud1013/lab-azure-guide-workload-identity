# /// script
# dependencies = ["azure-identity", "google-auth[requests]", "openai"]
# ///
# GCP Service Account 로 Azure Foundry gpt-image 모델 호출 (API key 없음)
#   uv run call_gpt_image.py --sa ... --project ... --tenant-id ... --client-id ... --endpoint ...
import argparse
import base64

import google.auth
from azure.identity import ClientAssertionCredential, get_bearer_token_provider
from google.auth import impersonated_credentials
from google.auth.transport.requests import Request
from openai import OpenAI

AUDIENCE = "api://AzureADTokenExchange"

parser = argparse.ArgumentParser(description="GCP Service Account 로 Azure Foundry gpt-image 모델 호출")
parser.add_argument("--sa", required=True, help="GCP Service Account ID (예: sa-aoai-gpt-image)")
parser.add_argument("--project", help="GCP project ID (기본값: gcloud ADC 의 project)")
parser.add_argument("--tenant-id", required=True, help="Microsoft Entra ID tenant ID")
parser.add_argument("--client-id", required=True, help="Managed Identity Client ID")
parser.add_argument("--endpoint", required=True, help="https://<foundry-name>.openai.azure.com")
parser.add_argument("--deployment", default="gpt-image-2.5-flare", help="배포 이름")
parser.add_argument("--prompt", default="A watercolor illustration of a bridge connecting a blue cloud and a multicolor cloud")
parser.add_argument("--output", default="output.png")
args = parser.parse_args()


# ① GCP SA 의 Google ID token (local: gcloud ADC 사용자가 SA 를 impersonate)
def google_id_token() -> str:
    # Cloud Run / Functions / GCE 에서는 아래 한 줄로 대체
    # return google.oauth2.id_token.fetch_id_token(Request(), AUDIENCE)
    source, adc_project = google.auth.default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
    # SA email = <SA ID>@<project ID>.iam.gserviceaccount.com
    sa_email = f"{args.sa}@{args.project or adc_project}.iam.gserviceaccount.com"
    sa = impersonated_credentials.Credentials(source, sa_email, source.scopes)
    token = impersonated_credentials.IDTokenCredentials(sa, target_audience=AUDIENCE, include_email=True)
    token.refresh(Request())
    return token.token


# ② ③ Google ID token → Entra ID access token (Managed Identity 의 Federated Credential)
credential = ClientAssertionCredential(args.tenant_id, args.client_id, google_id_token)

# ④ Foundry gpt-image 모델 호출
client = OpenAI(
    base_url=f"{args.endpoint.rstrip('/')}/openai/v1/",
    api_key=get_bearer_token_provider(credential, "https://cognitiveservices.azure.com/.default"),
)
result = client.images.generate(model=args.deployment, prompt=args.prompt, size="1024x1024", quality="low")

with open(args.output, "wb") as f:
    f.write(base64.b64decode(result.data[0].b64_json))
print(f"saved: {args.output}")
