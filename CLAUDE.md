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

Tema de login com o visual do admin (Raspala Admin, padrão "build-manager": dark por padrão, claro via
`prefers-color-scheme`, Inter/JetBrains Mono, cards flat). Herda do `base` (só a lógica FreeMarker) e traz CSS/JS
próprios — **não** carrega PatternFly.

```text
themes/raspadinha/login/
├── theme.properties            # parent=base; mapeia todas as classes kc* para classes rs-*
├── template.ftl                # layout (marca, card, seletor de idioma, alertas, footer); seção extra "subtitle"
├── login.ftl                   # formulário de login (mostrar/ocultar senha, lembrar-me, esqueci a senha, social)
├── messages/messages_{en,es,pt_BR}.properties   # chaves raspala* (acentos em \uXXXX: o Keycloak lê ISO-8859-1)
└── resources/{css/login.css, js/password-toggle.js, img/favicon.ico}
```

Regras ao evoluir:

- Cores/tipografia: só em `resources/css/login.css` (tokens no `:root` e no bloco `prefers-color-scheme: light`).
- Outras páginas do fluxo (reset de senha, erro, OTP, update password) usam o `template.ftl` e as classes `rs-*`
  via `theme.properties`; para mudar o HTML de uma delas, copie o `.ftl` de `reference/keycloak-19.0.2/base/login/`.
- Strings novas: adicione a chave nos três `messages_*.properties`, sempre com escapes `\uXXXX` para não-ASCII.
- `<!-- -->` não é comentário para o FreeMarker: nunca deixe `$` + `{...}` dentro de comentários HTML.

Teste local (renderiza o tema num Keycloak 19 descartável, sem tocar no servidor):

```bash
docker run --rm -p 8081:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v "$PWD/themes:/opt/keycloak/themes:ro" \
  quay.io/keycloak/keycloak:19.0.2 start-dev \
  --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false
# Realm settings → Themes → Login theme → raspadinha, depois abra
# http://localhost:8081/realms/<realm>/protocol/openid-connect/auth?client_id=<client>&response_type=code&redirect_uri=<uri>
```

No Admin Console do realm: **Realm settings → Themes → Login theme → `raspadinha`**. Reinicie o Keycloak para recarregar
mudanças de tema em produção:

```bash
sudo docker compose restart keycloak
```

## Remoção do legado

A stack antiga usa os containers `sys_rasp_keycloak` e `sys_rasp_keycloak_db` e o volume `sys_rasp_keycloak_db`. Só remova o volume antigo depois que o novo Keycloak estiver saudável, o realm importado e os client secrets restaurados. A API não é modificada neste repositório.
