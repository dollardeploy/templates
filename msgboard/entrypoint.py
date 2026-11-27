"""Start msgboard with an operator (admin) token derived from MSGBOARD_SECRET.

The token is stable across restarts and redeploys while MSGBOARD_SECRET stays the same.
Changing MSGBOARD_SECRET and redeploying rotates it; the old token is revoked on start.
"""

import base64
import hashlib
import os
import sys


def operator_token(seed: str) -> str:
    """Build a valid msgboard token: fbt_<16 hex credential id>.<base64url of 32 secret bytes>."""
    cred_id = hashlib.sha256(b"msgboard-credential:" + seed.encode()).hexdigest()[:16]
    secret = hashlib.sha256(b"msgboard-secret:" + seed.encode()).digest()
    secret_text = base64.urlsafe_b64encode(secret).rstrip(b"=").decode()
    return f"fbt_{cred_id}.{secret_text}"


seed = os.environ.get("MSGBOARD_SECRET", "").strip()
if len(seed) < 32:
    sys.exit("MSGBOARD_SECRET must be set to a random value of at least 32 characters")

token = operator_token(seed)
os.environ["MSGBOARD_OPERATOR_TOKEN"] = token
print(f"msgboard operator token: {token}", flush=True)

# Imported after the token is set: msgboard.space.app reads its environment at import time.
# It logs "MSGBOARD_REPLICA not set: all data is lost" because it assumes a Space's ephemeral disk;
# here MSGBOARD_DATA_DIR is a persistent Docker volume, so the board survives restarts.
from msgboard.space.app import main  # noqa: E402

main()
