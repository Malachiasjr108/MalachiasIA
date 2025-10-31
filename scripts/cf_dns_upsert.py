#!/usr/bin/env python3
import requests
import argparse

parser = argparse.ArgumentParser(description="Create or update DNS record in Cloudflare")
parser.add_argument("--zone-id", required=True, help="Cloudflare Zone ID")
parser.add_argument("--token", required=True, help="Cloudflare API Token")
parser.add_argument("--name", required=True, help="DNS record name (ex: malachias.108mia.com)")
parser.add_argument("--type", default="CNAME", help="DNS record type")
parser.add_argument("--content", required=True, help="DNS record content (target)")
parser.add_argument("--proxied", action="store_true", help="Proxy through Cloudflare (orange cloud)")
args = parser.parse_args()

print(f"🔧 Criando/atualizando DNS: {args.name} → {args.content}")

headers = {
    "Authorization": "Bearer " + args.token,
    "Content-Type": "application/json"
}

url = f"https://api.cloudflare.com/client/v4/zones/{args.zone_id}/dns_records"

payload = {
    "type": args.type,
    "name": args.name,
    "content": args.content,
    "proxied": args.proxied
}

response = requests.post(url, headers=headers, json=payload)

if response.status_code == 200 and response.json().get("success"):
    print("✅ DNS criado/atualizado com sucesso!")
else:
    print("❌ Falha ao criar/atualizar DNS:")
    print(response.text)
