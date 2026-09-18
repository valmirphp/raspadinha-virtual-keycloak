# Keycloak — desenvolvimento e customização

Este repositório é responsável **somente pelo Keycloak e seus temas**. A API `raspadinha-virtual-api-graphql` não deve ser alterada para mudanças daqui.

## Pré-requisitos

- Docker Engine com Docker Compose v2
- A rede Docker externa `sys_rasp`
- O volume Docker externo `sys_rasp_keycloak_db` (para usar os dados já existentes)

Confira antes de subir:

```bash
docker network inspect sys_rasp
docker volume inspect sys_rasp_keycloak_db
```

## Rodar localmente

1. Crie seu arquivo de variáveis e defina senhas reais:

```bash
cp .env.example .env
chmod 600 .env
```

2. Valide a composição sem iniciar containers:

```bash
docker compose config
```

3. **Migração controlada:** o `docker-compose.yaml` da API continua intacto por enquanto, mas ele ainda declara os mesmos serviços/volume de Keycloak. Não deixe os dois projetos subirem Keycloak ao mesmo tempo, ou haverá conflito de porta e de acesso ao banco. Pare somente os serviços Keycloak do projeto antigo antes de iniciar este:

```bash
cd ../raspadinha-virtual-api-graphql
docker compose stop keycloak keycloak_db
cd ../raspadinha-virtual-keycloak
docker compose up -d
```

4. Acompanhe o boot e acesse `http://localhost:8077`:

```bash
docker compose logs -f keycloak
docker compose ps
curl -fsS http://localhost:8077/health/ready
```

Para parar sem apagar os dados:

```bash
docker compose down
```

Nunca rode `docker compose down -v` neste projeto: o volume é externo e contém os dados do Keycloak.

## Tema `raspadinha`

O tema inicial herda do tema base `keycloak` e aplica fundo verde na tela de login:

```text
themes/raspadinha/login/
├── theme.properties
└── resources/css/styles.css
```

No Admin Console:

1. Abra o realm desejado.
2. Vá em **Realm settings → Themes**.
3. Em **Login theme**, escolha `raspadinha` e salve.
4. Abra uma aba anônima para validar a tela de login.

### Customizar

- CSS: edite `themes/raspadinha/login/resources/css/styles.css`.
- Templates: só crie `login/*.ftl` quando precisar mudar a estrutura HTML. Eles sobrescrevem os arquivos do tema pai; não copie template à toa — esse é o jeito mais rápido de ganhar uma manutenção chata em atualização do Keycloak.
- Recursos estáticos (logos/imagens): use `themes/raspadinha/login/resources/` e referencie-os no CSS ou template.

Após alterar CSS/recursos em desenvolvimento, reinicie o serviço para garantir que o Keycloak releia o tema:

```bash
docker compose restart keycloak
```

## Regras de segurança

- Não versione `.env`, exports de realm, client secrets ou senhas.
- Não habilite `KC_FEATURES=scripts` só para importar políticas JavaScript legadas; migre-as antes.
- Para produção, não use `start-dev`; defina hostname, proxy/TLS e execute `start` com configuração revisada.
