# /// script
# dependencies = ["azure-identity", "openai"]
# ///
# GCP Service Account 로 Azure Foundry gpt-image 모델 호출 (API key 없음)
#   uv run call_gpt_image.py --sa ... --project ... --tenant-id ... --client-id ... --endpoint ...
import argparse
import base64
import subprocess

from azure.identity import ClientAssertionCredential, get_bearer_token_provider
from openai import OpenAI

AUDIENCE = "api://AzureADTokenExchange"

parser = argparse.ArgumentParser(description="GCP Service Account 로 Azure Foundry gpt-image 모델 호출")
parser.add_argument("--sa", required=True, help="GCP Service Account ID (email 의 @ 앞부분)")
parser.add_argument("--project", required=True, help="SA 가 있는 GCP project ID")
parser.add_argument("--tenant-id", required=True, help="Microsoft Entra ID tenant ID")
parser.add_argument("--client-id", required=True, help="Managed Identity Client ID")
parser.add_argument("--endpoint", required=True, help="https://<foundry-name>.openai.azure.com")
parser.add_argument("--deployment", default="gpt-image-2.5-flare", help="배포 이름")
parser.add_argument("--prompt", default="A watercolor illustration of a bridge connecting a blue cloud and a multicolor cloud")
parser.add_argument("--output", default="output.png")
args = parser.parse_args()


# ① GCP SA 의 Google ID token (local: gcloud auth login 사용자가 SA 를 impersonate)
def google_id_token() -> str:
    # SA email = <SA ID>@<project ID>.iam.gserviceaccount.com
    sa_email = f"{args.sa}@{args.project}.iam.gserviceaccount.com"
    cmd = [
        "gcloud", "auth", "print-identity-token",
        f"--impersonate-service-account={sa_email}",
        f"--audiences={AUDIENCE}",
        "--include-email",
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"{sa_email} 의 ID token 발급 실패 (project ID, Token Creator 권한 확인)\n{e.stderr.strip()}") from e
    return result.stdout.strip()


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
