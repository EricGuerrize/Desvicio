# Desvício

Um bichinho virtual que reage ao tempo gasto nos aplicativos que você escolheu controlar. A proposta combina limites de uso, sessões de foco e um jogo de cuidado com linguagem brasileira.

## Ideia central

**Cuide do seu tempo. Seu bichinho sente a diferença.**

O usuário escolhe os aplicativos que mais o distraem e define uma meta diária. Na metade da meta, o bichinho fica cansado; no limite, fica dodói; após mais 30 minutos, vira um fantasminha e os apps escolhidos são bloqueados. Uma nova jornada começa no dia seguinte.

O bichinho reage apenas aos apps selecionados, não ao uso necessário do celular. Widget e notificações são ideias para uma versão futura.

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
- Sessões de foco de 15, 25 ou 45 minutos bloqueiam os apps escolhidos durante a pausa. Ao terminar, recuperam parte da energia, exceto no estágio final do dia.
- O estado crítico é reversível. O jogo mostra progresso e recomeços, sem streaks que zeram tudo após um dia ruim.

Esses valores são hipóteses de produto para testar, não regras definitivas.

## Personalidade

Visual de brinquedo digital brasileiro: expressivo, acolhedor e com humor leve. Linguagem curta, sem bronca: “Bora dar uma respirada?”, “Seu bichinho tá pedindo um intervalo”. O personagem, nome, ilustrações e interface devem ser originais.

## Plataforma e viabilidade

Para controlar e bloquear outros aplicativos no iPhone, a implementação precisa ser nativa e usar **Family Controls**, **Device Activity** e **Managed Settings**. O usuário precisa conceder autorização. A distribuição também depende da permissão da Apple para o recurso Family Controls no aplicativo e nas extensões necessárias.

O projeto atual implementa o fluxo principal, o monitoramento por marcos de uso, o bloqueio no último estágio e pausas de foco que também bloqueiam os apps escolhidos. Ainda não inclui widget, notificações, histórico de sete dias, itens cosméticos nem um relatório de minutos exatos. A pausa registra o tempo do cronômetro; ela não verifica se a pessoa deixou de usar outros apps.

O app não cria conta e não oferece login Google ou Apple. Todas as informações que ele salva ficam no iPhone. Em **Ajustes → Apagar meus dados deste iPhone**, o usuário pode interromper o controle e limpar esses dados. Leia a [política de privacidade](PRIVACY.md) e a [preparação para a App Store](APP_STORE.md).

## Visualizar no Xcode

1. Abra [`Desvicio.xcodeproj`](Desvicio.xcodeproj) no Xcode, selecione o esquema **Desvicio** e um simulador de iPhone na barra superior.
2. Pressione **⌘R** para ver a tela de boas-vindas no simulador.
3. Para visualizar a tela principal sem configurar o Tempo de Uso, abra `Desvicio/App/RootView.swift`, escolha **Editor → Canvas** e veja as prévias **Boas-vindas** e **Tela do bichinho**.

O projeto foi compilado sem assinatura para iPhone e simulador com Xcode 27. A tela inicial foi aberta no simulador. O simulador não valida o controle real de outros apps.

## Testar no iPhone

1. Entre com sua conta Apple em **Xcode → Settings → Apple Accounts** e selecione sua equipe em **Signing & Capabilities** nos alvos **Desvicio** e **DesvicioMonitor**.
2. Configure identificadores de bundle próprios, registre um App Group e use o mesmo identificador nos dois arquivos de entitlements e em `DesvicioConfig.groupID`.
3. Habilite **Family Controls** e **App Groups** para os dois alvos. Instale no iPhone e conceda a autorização de Tempo de Uso no primeiro acesso.
4. Verifique o bloqueio real nos marcos de uso e durante uma sessão de foco.

O alvo mínimo é iOS 17.4. A conta Apple gratuita permite desenvolver e visualizar o app, mas não permite distribuí-lo na App Store ou TestFlight. As capacidades avançadas podem exigir a adesão ao Apple Developer Program antes mesmo do teste completo no iPhone. A distribuição também exige que a Apple aprove **Family Controls (Distribution)** para o app e a extensão.

## Decisões abertas

- Nome final: **Desvício** é mais marcante e comunica a proposta; **Desapego** é mais suave e amplo.
- Personagem e estilo visual.
- Modelo gratuito e eventuais itens pagos.

## Referências

- [Brainrot: Screen Time Control na App Store](https://apps.apple.com/br/app/brainrot-screen-time-control/id6744338972)
- [Screen Time Technology Frameworks, Apple Developer](https://developer.apple.com/documentation/screentimeapidocumentation/)
- [Configuring Family Controls, Apple Developer](https://developer.apple.com/documentation/Xcode/configuring-family-controls)
- [Requesting the Family Controls entitlement, Apple Developer](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement)
