# Referência dos temas internos do Keycloak 19.0.2

Este diretório contém uma cópia **de referência** dos temas `base` e `keycloak` empacotados na imagem `quay.io/keycloak/keycloak:19.0.2` usada no deploy.

- Não é montado como tema customizado em runtime.
- Serve para o frontend comparar CSS, imagens, mensagens e templates FTL da versão exata do Keycloak em uso.
- O tema ativo continua em `../../themes/raspadinha`.
- `themes/raspadinha/login/login.ftl` começou como cópia idêntica de `base/login/login.ftl`.

Ao atualizar a versão do Keycloak, regenere esta referência a partir do JAR `org.keycloak.keycloak-themes-<versão>.jar`. Não copie arquivos de uma versão diferente: templates FTL têm acoplamentos bem chatos com macros e atributos internos. Surpresa nenhuma, só o clássico presente de framework.
