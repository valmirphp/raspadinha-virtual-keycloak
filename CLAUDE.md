# Keycloak Raspadinha — operação e customização

Este repositório opera **somente** o Keycloak, seu banco MariaDB, o realm e os temas. A API `raspadinha-virtual-api-graphql` não deve ser editada como parte deste projeto.

## Arquitetura de deploy

- URL pública: `https://auth-raspadinha.dploy.space`
- Proxy/TLS: Traefik, rede Docker externa `edge`
- Keycloak: `quay.io/keycloak/keycloak:19.0.2`
- Banco: volume Docker próprio `raspadinha-keycloak_keycloak-db`
- Não há `ports:` publicados: o Traefik é a única entrada pública.

## Segredos

Nunca versione `.env`, senhas de banco, senha do admin ou secrets de client. Em servidor, guarde-os no arquivo seguro de ambiente da stack (modo `600`) e rode o Compose com `--env-file`.

Variáveis obrigatórias:

```dotenv
MYSQL_ROOT_PASSWORD=<senha-aleatoria>
KC_DB_PASSWORD=<senha-aleatoria>
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=<senha-aleatoria>
```

## Realm importado

- `keycloak/import/realm-export.json` é o export recebido e permanece versionado por solicitação explícita.
- Esse export contém duas policies JavaScript legadas. Keycloak 19 bloqueia esse formato em imports; não habilite `KC_FEATURES=scripts` em deploy apenas para contornar o bloqueio.
- `scripts/prepare-realm-import.py` gera `keycloak/import/realm-import.json`, que substitui somente essas policies incondicionais por uma policy de role `uma_authorization`, já default no realm. Isso preserva a intenção sem reabrir execução de JavaScript no servidor.

Sempre regenere e revise antes de alterar o export:

```bash
python3 scripts/prepare-realm-import.py
python3 -m json.tool keycloak/import/realm-import.json >/dev/null
```

O export mascara secrets de clients. Após uma importação em banco novo, restaure ou rotacione os secrets de todos os clients confidenciais antes de encaminhar tráfego dependente deles.

## Subir no servidor

```bash
# Validar o render antes de tocar no Docker
docker compose --env-file /caminho/seguro/.env config --quiet

# Subir (Keycloak importa o realm apenas se ele ainda não existir)
sudo docker compose --env-file /caminho/seguro/.env up -d

# Verificar estado e logs
sudo docker compose ps
sudo docker compose logs --tail=150 keycloak
```

O deploy só está pronto após validar pela rota pública:

```bash
curl -fsS https://auth-raspadinha.dploy.space/realms/rasp-dev/.well-known/openid-configuration
```

Confirme que `issuer`, `authorization_endpoint` e `token_endpoint` começam com `https://auth-raspadinha.dploy.space/`.

## Tema `raspadinha`

O tema herda do tema base `keycloak` e inicia com fundo verde:

```text
themes/raspadinha/login/
├── theme.properties
└── resources/css/styles.css
```

No Admin Console do realm: **Realm settings → Themes → Login theme → `raspadinha`**.

- Para cores/layout leve: altere `resources/css/styles.css`.
- Para logo/imagens: adicione arquivos em `resources/`.
- Crie templates `*.ftl` apenas quando precisar mudar HTML. Copiar templates do pai só para mexer num detalhe é dívida técnica com gravidade marciana.
- Reinicie o Keycloak para recarregar mudanças de tema:

```bash
sudo docker compose restart keycloak
```

## Remoção do legado

A stack antiga usa os containers `sys_rasp_keycloak` e `sys_rasp_keycloak_db` e o volume `sys_rasp_keycloak_db`. Só remova o volume antigo depois que o novo Keycloak estiver saudável, o realm importado e os client secrets restaurados. A API não é modificada neste repositório.
