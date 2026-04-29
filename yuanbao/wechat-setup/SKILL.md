---
name: wechat-setup
description: "Set up or re-login WeChat gateway for Hermes Agent — supports both Docker and non-Docker deployments."
version: 1.1.0
author: Hermes Agent
---

# WeChat Setup / Re-Login

Set up WeChat (Weixin) gateway for Hermes Agent via QR code login. The workflow differs based on deployment mode.

## Deployment Mode Detection

First determine which mode applies:

```bash
# Check if running in Docker
cat /proc/1/cgroup 2>/dev/null | grep -q docker && echo "DOCKER" || echo "NON-DOCKER"

# Alternative: check for tini as PID 1
ps -p 1 -o comm= | grep -q tini && echo "DOCKER (tini)" || echo "NON-DOCKER"
```

### Non-Docker Mode (e.g. bare metal, VM, WSL)

Single continuous session. After saving credentials, just `hermes gateway restart` — the gateway restarts independently without affecting the agent's CLI/TUI session.

**Flow:** Generate QR → scan → save credentials → `hermes gateway restart` → verify → pair → done ✓

### Docker Mode

**Two-part workflow** required. Gateway restart terminates the container's main process (managed by tini), which kills any active TUI/CLI session. The agent can't survive this restart, so credentials are saved in Part 1, and the user runs `docker restart <container>` from the host. Part 2 resumes fresh after the container comes back.

## Prerequisites

- Hermes Agent running in Docker (standard deployment)
- Dependencies in Hermes venv: `aiohttp`, `cryptography`, `qrcode`
- Verify: `/opt/hermes/.venv/bin/python3 -c "import aiohttp, cryptography, qrcode; print('OK')"`
- Container name (e.g. `hermes-user1`) — confirm with `docker ps` or check the compose file

## Part 1 — Generate QR + Save Credentials

### 0. Determine mode and set expectations

```bash
# Check Docker vs non-Docker
if ps -p 1 -o comm= | grep -q tini; then
    echo "DOCKER MODE — two-part workflow. Session will die after docker restart."
else
    echo "NON-DOCKER MODE — single session. Gateway restart is safe."
fi
```

### 1. Check current state

```bash
# .env: check existing WEIXIN_* vars
grep "^WEIXIN" /opt/data/.env

# Gateway state
cat /opt/data/gateway_state.json

# Gateway logs (last 20 lines)
tail -20 /opt/data/logs/gateway.log
```

### 2. Generate QR code and poll for confirmation

Write a Python script to:
1. Call iLink API: `ilink/bot/get_bot_qrcode?bot_type=3` to get `qrcode_img_content` (URL) and `qrcode` (hex token)
2. Display the scan URL to the user (liteapp.weixin.qq.com/q/...)
3. Also render an ASCII QR as fallback
4. Poll `ilink/bot/get_qrcode_status?qrcode=<hex>` until status = `"confirmed"`
5. Extract: `ilink_bot_id`, `bot_token`, `baseurl`, `ilink_user_id`

**Important:** The polling must run in a background process with status written to a file (asyncio stdout doesn't flush reliably into process tool output):

```python
STATUS_FILE = "/tmp/wechat_status.json"
write_status("waiting")
```

**Pitfalls:**
- QR code expires in ~3-8 minutes. Be prompt.
- The URL (not the hex) is what the user scans/opens. The hex is only for polling.
- `bot_token` format: `<account_id>:<hex_token>` — keep the full string.
- Run the script as a **background** process with `notify_on_complete=true` so you're alerted when confirmed.
- If background process output doesn't show progress, read `/tmp/wechat_status.json` directly.

### 3. Once confirmed — save credentials

```python
import sys
sys.path.insert(0, '/opt/hermes')
from gateway.platforms import weixin as wx
from hermes_constants import get_hermes_home

hermes_home = get_hermes_home()
wx.save_weixin_account(hermes_home,
    account_id=account_id,
    token=token,          # full token with colon
    base_url=base_url,
    user_id=user_id)
```

Then update `.env` via Python (sed will truncate tokens with special chars):

```python
import re
with open('/opt/data/.env', 'r') as f:
    content = f.read()
content = re.sub(r'^WEIXIN_ACCOUNT_ID=.*$', f'WEIXIN_ACCOUNT_ID={new_account_id}', content, flags=re.MULTILINE)
content = re.sub(r'^WEIXIN_TOKEN=.*$', f'WEIXIN_TOKEN={new_token}', content, flags=re.MULTILINE)
with open('/opt/data/.env', 'w') as f:
    f.write(content)
```

**Pitfalls:** Do NOT use `sed` — the token contains `@` and `:` characters that get truncated. Always use Python `re.sub`.

### 4. Save memory for Part 2

```python
# The new credentials must survive the session kill:
memory.add(content=f"New WeChat credentials saved: account_id={account_id}, token saved to .env and account file. Gateway restart pending.")
```

### 5. Instruct user based on deployment mode

**If Non-Docker mode:**

```bash
# Restart gateway — safe, won't kill session
hermes gateway restart
```
Then proceed to Part 2 — Verify + Pair (continue in same session).

**If Docker mode:**

Tell the user **clearly and prominently**:

> **Part 1 complete!** Now run this from the **host machine** (not inside the container):
> ```
> docker restart <container-name>
> ```
> After the container restarts, come back and tell me to continue — I'll verify the connection and handle pairing.

**Important:** The `docker restart` will kill this session. The chat is auto-saved. The user can resume with `hermes --continue` or just start a new session and say "continue wechat setup".

## Part 2 — Verify + Pair (Fresh Session)

The user returns after running `docker restart`. The agent is in a fresh session with no context.

### 1. Recover context

Use `session_search` to find Part 1's outcome:

```
session_search(query="wechat setup QR login credentials saved")
```

### 2. Verify gateway connected with new credentials

```bash
cat /opt/data/gateway_state.json
tail -20 /opt/data/logs/gateway.log
```

Look for:
```
[Weixin] Connected account=<new_account_prefix> base=https://ilinkai.weixin.qq.com
✓ weixin connected
Gateway running with 1 platform(s)
```

### 3. Handle pairing (if DM policy = pairing)

The user sends a message from WeChat. The bot replies with a pairing code. The user provides the code.

```bash
# Check pending pairings
hermes pairing list

# Approve
hermes pairing approve weixin <CODE>
```

### 4. Confirm with user

Tell the user to send another message to verify the bot responds.

## Full Script Template (Part 1)

Save this as a reference script:

```python
#!/opt/hermes/.venv/bin/python3
"""WeChat QR login - Part 1: Generate QR, poll, save credentials."""

import asyncio, aiohttp, sys, time, json, os, re, qrcode as qrlib

STATUS_FILE = "/tmp/wechat_qr_status.json"
sys.path.insert(0, "/opt/hermes")
from gateway.platforms import weixin as wx
from hermes_constants import get_hermes_home

def write_status(status, detail="", **extra):
    data = {"status": status, "detail": detail, **extra}
    with open(STATUS_FILE, "w") as f:
        json.dump(data, f)
    print(f"[STATUS] {json.dumps(data)}", flush=True)

async def main():
    hermes_home = get_hermes_home()
    async with aiohttp.ClientSession(trust_env=True) as session:
        # Get QR
        resp = await wx._api_get(session, base_url=wx.ILINK_BASE_URL,
            endpoint=f"{wx.EP_GET_BOT_QR}?bot_type=3", timeout_ms=wx.QR_TIMEOUT_MS)
        qrcode_url = str(resp.get("qrcode_img_content") or "")
        qrcode_value = str(resp.get("qrcode") or "")
        scan_data = qrcode_url or qrcode_value
        if not scan_data:
            write_status("error", "No QR data from API")
            return

        # Display
        print(f"QR URL: {scan_data}", flush=True)
        qr = qrlib.QRCode(border=1, box_size=1)
        qr.add_data(scan_data)
        qr.make(fit=True)
        qr.print_ascii(invert=True)

        # Poll
        write_status("waiting", "QR displayed", qr_url=scan_data)
        deadline = time.time() + 480
        while time.time() < deadline:
            try:
                status_resp = await wx._api_get(session, base_url=wx.ILINK_BASE_URL,
                    endpoint=f"{wx.EP_GET_QR_STATUS}?qrcode={qrcode_value}",
                    timeout_ms=wx.QR_TIMEOUT_MS)
            except:
                await asyncio.sleep(2); continue
            status = str(status_resp.get("status") or "wait")
            if status == "confirmed":
                account_id = str(status_resp.get("ilink_bot_id") or "")
                token = str(status_resp.get("bot_token") or "")
                base_url = str(status_resp.get("baseurl") or wx.ILINK_BASE_URL)
                user_id = str(status_resp.get("ilink_user_id") or "")
                if not account_id or not token:
                    write_status("error", "No credentials")
                    return

                # Save account JSON
                wx.save_weixin_account(hermes_home,
                    account_id=account_id, token=token,
                    base_url=base_url, user_id=user_id)

                # Save .env
                env_path = os.path.join(hermes_home, ".env")
                with open(env_path, "r") as f:
                    content = f.read()
                content = re.sub(r'^WEIXIN_ACCOUNT_ID=.*$',
                    f'WEIXIN_ACCOUNT_ID={account_id}', content, flags=re.MULTILINE)
                content = re.sub(r'^WEIXIN_TOKEN=.*$',
                    f'WEIXIN_TOKEN={token}', content, flags=re.MULTILINE)
                with open(env_path, "w") as f:
                    f.write(content)

                write_status("success", "Credentials saved",
                    account_id=account_id, base_url=base_url)
                return
            elif status == "expired":
                write_status("expired", "QR expired"); return
            else:
                await asyncio.sleep(2)

        write_status("timeout", "Poll deadline exceeded")

asyncio.run(main())
```
