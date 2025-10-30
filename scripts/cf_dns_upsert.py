#!/usr/bin/env python3
import argparse, requests, json

parser = argparse.ArgumentParser()
parser.add_argument("--zone-id", required=True)
parser.add_argument("--token", required=True)
parser.add_argument("--name", required=True)
parser.add_argument("--type", default="CNAME")
parser.add_argument("--content", required=True)
parser.add_argument("--proxied", default="true")
args = parser.parse_args()

headers = {"Authorization": f"Bearer {args.token}", "Content-Type": "application/json"}
url = f"https://api.cloudflare.com/client/v4/zones/{args.zone-id}/dns_records"
payload = {"type": args.type, "name": args.name, "content": args.content, "proxied": args.proxied.lower()=="true"}

r = requests.get(url, headers=headers, params={"name": args.name})
r.raise_for_status()
result = r.json()["result"]

if result:
    rec_id = result[0]["id"]
    u = requests.put(f"{url}/{rec_id}", headers=headers, data=json.dumps(payload))
    print("🌀 DNS atualizado:", u.json())
else:
    c = requests.post(url, headers=headers, data=json.dumps(payload))
    print("🌍 DNS criado:", c.json())
