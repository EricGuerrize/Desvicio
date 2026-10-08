# Preparação para a App Store

Esta lista descreve o estado atual do projeto. A aprovação final cabe à Apple.

## Implementado

- Interface Flutter em português brasileiro, com controle de Tempo de Uso nativo em Swift e extensão de monitoramento para iPhone. A base Android ainda não oferece controle de uso.
- Sem cadastro, login social, servidor, anúncios ou compras. A regra de login equivalente da diretriz 4.8 não se aplica ao fluxo atual.
- Seleção de apps, categorias e sites pelo controle de privacidade da Apple.
- Autorização individual para o Tempo de Uso, monitoramento diário, estados do bichinho e bloqueio no estágio final.
- Extensão de configuração do escudo (`com.desvicio.app.shield`) com texto do bichinho ou da pausa de foco. O visual ainda não foi visto em iPhone físico.
- Ação dentro do app para interromper o controle e apagar os dados locais.
- Política de privacidade acessível dentro do app e no repositório público; contato de privacidade e página de suporte ainda pendentes.
- Ícone original no catálogo de ativos.
- Manifestos de privacidade no app e na extensão para o uso de `UserDefaults`.

## Antes de testar no iPhone

1. Escolher uma equipe Apple Developer para os dois alvos no Xcode.
2. Registrar `com.desvicio.app`, `com.desvicio.app.monitor`, `com.desvicio.app.shield` e o App Group `group.com.desvicio.app`.
3. Ativar Family Controls e App Groups para o app, o monitor e o escudo. Confirmar que os perfis de desenvolvimento incluem as capacidades.
4. Testar autorização concedida, negada e revogada; seleção vazia; metade da meta; meta; 30 minutos extras; virada do dia; troca de meta e seleção; exclusão de dados.
5. Testar no iPhone real. O simulador serve para verificar a interface, mas não substitui os testes da API de Tempo de Uso.

## Antes de enviar à App Store

1. Solicitar à Apple a capacidade **Family Controls (Distribution)** para o app, o monitor e o escudo. Sem a aprovação, o arquivo de distribuição pode não ser assinado.
2. Informar no App Store Connect a URL pública da política de privacidade (`https://github.com/EricGuerrize/Desvicio/blob/main/PRIVACY.md`) e declarar corretamente as práticas de coleta. Recomenda-se publicar uma página estável antes do envio.
3. Definir uma página pública de suporte com contato adequado, completar a seção de contato da política e mantê-la atualizada.
4. Validar o ícone final e criar capturas de tela reais, descrição, palavras-chave, classificação etária e informações de revisão.
5. Explicar ao revisor que o app usa autorização individual de Tempo de Uso e informar o passo a passo para selecionar apps e reproduzir o bloqueio. Um vídeo em iPhone real pode ajudar se o fluxo for difícil de reproduzir.
6. Testar um build Release assinado em aparelho real antes de enviar.
7. Revisar nome, personagem, imagens e textos para garantir identidade própria, sem copiar ativos do Brainrot ou de outros apps.

## Se contas forem adicionadas no futuro

Se o app oferecer Google ou outro login social para a conta principal, deverá oferecer uma opção equivalente que atenda à diretriz 4.8 da Apple. Se criar contas, deverá permitir iniciar a exclusão dentro do app e apagar o registro e os dados associados; com Sign in with Apple, também deverá tratar a revogação dos tokens. Essas exigências não são atendidas por apenas mostrar um botão sem backend de exclusão.

## Referências oficiais

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Login Services, diretriz 4.8](https://developer.apple.com/app-store/review/guidelines/#login-services)
- [Account deletion, diretriz 5.1.1(v)](https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion/)
- [Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement)
- [App privacy no App Store Connect](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)
