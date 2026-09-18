#!/usr/bin/env python3
"""Gera um import compatível com Keycloak 19 a partir do export legado."""
import json
from pathlib import Path

source = Path("keycloak/import/realm-export.json")
target = Path("keycloak/import/realm-import.json")
realm = json.loads(source.read_text(encoding="utf-8"))

# O Keycloak moderno bloqueia policy JavaScript embutida em realm import. As
# policies legadas abaixo apenas chamavam $evaluation.grant(), ou seja, davam
# acesso a todo usuário do realm. `uma_authorization` já é role default no
# export e preserva essa semântica sem habilitar upload/execução de JS.
role_id = next(
    role["id"]
    for role in realm["roles"]["realm"]
    if role["name"] == "uma_authorization"
)
for client in realm.get("clients", []):
    for policy in client.get("authorizationSettings", {}).get("policies", []):
        if policy.get("type") == "js" and policy.get("config", {}).get("code", "").strip() == "// by default, grants any permission associated with this policy\n$evaluation.grant();":
            policy["type"] = "role"
            policy["config"] = {"roles": json.dumps([{ "id": role_id, "required": True }])}

target.write_text(json.dumps(realm, indent=2) + "\n", encoding="utf-8")
print(f"Generated {target}")
