# Desvício

Um bichinho virtual que reage ao tempo gasto nos aplicativos que você escolheu controlar. A proposta combina limites de uso, sessões de foco e um jogo de cuidado com linguagem brasileira.

## Ideia central

**Cuide do seu tempo. Seu bichinho sente a diferença.**

O usuário escolhe os aplicativos que mais o distraem e define uma meta diária realista. Dentro da meta, o bichinho fica bem. Ao ultrapassá-la, ele perde energia, muda de expressão e seu ambiente fica mais bagunçado. Períodos longe desses aplicativos restauram energia e rendem itens para cuidar dele. No estado mais crítico, ele vira um fantasminha por um tempo, mas sempre pode ser recuperado.

O bichinho reage apenas aos apps selecionados, não ao uso necessário do celular. O jogo não pede que a pessoa abra o Desvício várias vezes ao dia: o estado principal deve aparecer em widget e notificações opcionais.

## Visão para a primeira versão pública

1. **Início:** escolher o bichinho, dar um nome e definir uma meta diária para apps escolhidos.
2. **Hoje:** mostrar o bichinho, tempo usado, tempo restante e uma ação rápida para começar um período de foco.
3. **Limite:** o bichinho piora ao atingir a meta e os apps escolhidos são bloqueados após 30 minutos extras.
4. **Cuidado:** melhorar o estado do bichinho ao cumprir pausas e sessões de foco; desbloquear itens cosméticos simples.
5. **Resumo:** mostrar a evolução dos últimos sete dias e permitir ajustar a meta sem punição.

## Regras iniciais do jogo

- Começar com uma meta sugerida de 2 horas por dia nos apps escolhidos; o usuário pode alterá-la.
- O estado do bichinho tem quatro níveis: **animado**, **cansado**, **dodói** e **fantasminha**.
- A piora acontece na metade da meta, no limite e após 30 minutos extras. O bloqueio ocorre no último estágio.
- Uma pausa de 20 minutos ou uma sessão de foco de 25 minutos recupera parte da energia.
- O estado crítico é reversível. O jogo mostra progresso e recomeços, sem streaks que zeram tudo após um dia ruim.

Esses valores são hipóteses de produto para testar, não regras definitivas.

## Personalidade

Visual de brinquedo digital brasileiro: expressivo, acolhedor e com humor leve. Linguagem curta, sem bronca: “Bora dar uma respirada?”, “Seu bichinho tá pedindo um intervalo”. O personagem, nome, ilustrações e interface devem ser originais.

## Plataforma e viabilidade

Para controlar e bloquear outros aplicativos no iPhone, a implementação precisa ser nativa e usar **Family Controls**, **Device Activity** e **Managed Settings**. O usuário precisa conceder autorização. A distribuição também depende da permissão da Apple para o recurso Family Controls no aplicativo e nas extensões necessárias.

O projeto atual implementa o fluxo principal, o monitoramento por marcos de uso e o bloqueio no último estágio. Ainda não inclui widget, notificações, histórico de sete dias, itens cosméticos nem um relatório de minutos exatos. A pausa de foco é um cronômetro simples e não verifica se o celular foi realmente deixado de lado.

## Abrir e testar o projeto iOS

1. Abra `Desvicio.xcodeproj` no Xcode.
2. Nos alvos **Desvicio** e **DesvicioMonitor**, selecione sua equipe em *Signing & Capabilities*.
3. Registre identificadores de bundle próprios para os dois alvos e o mesmo App Group nos dois arquivos de entitlements. Atualize também `DesvicioConfig.groupID` em `SharedState.swift`.
4. Habilite **Family Controls** e **App Groups** para os dois alvos na conta Apple Developer. Para distribuir o app, solicite a permissão de distribuição do Family Controls também para a extensão.
5. Instale em um iPhone e conceda a autorização de Tempo de Uso no primeiro acesso. O controle de outros apps deve ser validado em um aparelho real.

O alvo mínimo é iOS 17.4. O código Swift dos dois alvos passou pela verificação de tipos com o SDK do iPhone; a compilação completa e a execução ainda precisam ser feitas no Xcode com a licença aceita e uma equipe de assinatura configurada.

## Decisões abertas

- Nome final: **Desvício** é mais marcante e comunica a proposta; **Desapego** é mais suave e amplo.
- Personagem e estilo visual.
- Plataforma inicial e formato da próxima entrega.
- Modelo gratuito e eventuais itens pagos.

## Referências

- [Brainrot: Screen Time Control na App Store](https://apps.apple.com/br/app/brainrot-screen-time-control/id6744338972)
- [Screen Time Technology Frameworks, Apple Developer](https://developer.apple.com/documentation/screentimeapidocumentation/)
- [Configuring Family Controls, Apple Developer](https://developer.apple.com/documentation/Xcode/configuring-family-controls)
- [Requesting the Family Controls entitlement, Apple Developer](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement)
