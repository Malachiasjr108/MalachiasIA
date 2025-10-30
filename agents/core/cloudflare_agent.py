#!/usr/bin/env python3
import os
import requests

# ===============================
# 🌩️ Malachias Cloudflare Agent
# ===============================
# Este módulo conecta o Malachias IA à Cloudflare via API
# Permite gerenciar zonas, DNS, e deploys automatizados

CLOUDFLARE_API_KEY = os.getenv("CLOUDFLARE_API_KEY")
BASE_URL = "https://api.cloudflare.com/client/v4"


def verify_token():
    """Verifica se o token Cloudflare é válido"""
    headers = {
        "Authorization": f"Bearer {CLOUDFLARE_API_KEY}",
        "Content-Type": "application/json"
    }
    response = requests.get(f"{BASE_URL}/user/tokens/verify", headers=headers)
    return response.json()


def list_zones():
    """Lista todas as zonas (domínios) da conta"""
    headers = {
        "Authorization": f"Bearer {CLOUDFLARE_API_KEY}",
        "Content-Type": "application/json"
    }
    response = requests.get(f"{BASE_URL}/zones", headers=headers)
    return response.json()


def list_dns_records(zone_id):
    """Lista todos os registros DNS de uma zona"""
    headers = {
        "Authorization": f"Bearer {CLOUDFLARE_API_KEY}",
        "Content-Type": "application/json"
    }
    response = requests.get(f"{BASE_URL}/zones/{zone_id}/dns_records", headers=headers)
    return response.json()


def create_dns_record(zone_id, record_type, name, content, ttl=3600, proxied=False):
    """Cria um novo registro DNS"""
    headers = {
        "Authorization": f"Bearer {CLOUDFLARE_API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "type": record_type,
        "name": name,
        "content": content,
        "ttl": ttl,
        "proxied": proxied
    }
    response = requests.post(f"{BASE_URL}/zones/{zone_id}/dns_records", headers=headers, json=data)
    return response.json()


def delete_dns_record(zone_id, record_id):
    """Deleta um registro DNS"""
    headers = {
        "Authorization": f"Bearer {CLOUDFLARE_API_KEY}",
        "Content-Type": "application/json"
    }
    response = requests.delete(f"{BASE_URL}/zones/{zone_id}/dns_records/{record_id}", headers=headers)
    return response.json()


if __name__ == "__main__":
    print("🌐 Verificando conexão com Cloudflare...")
    result = verify_token()
    if result.get("success"):
        print("✅ Conectado com sucesso à Cloudflare!")
        zones = list_zones()
        print(f"🌍 Zonas encontradas: {[z['name'] for z in zones.get('result', [])]}")
    else:
        print("❌ Falha na autenticação com Cloudflare.")
        print(result)
