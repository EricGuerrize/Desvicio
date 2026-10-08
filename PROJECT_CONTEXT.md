# Contexto do projeto Desvício

Atualizado em 8 de outubro de 2026. Este arquivo é o ponto de partida para uma nova conversa no terminal ou com outra IA. Leia também [README.md](README.md), [APP_STORE.md](APP_STORE.md) e [PRIVACY.md](PRIVACY.md).## Objetivo

Criar um app brasileiro de cuidado com o tempo de tela, onde o avatar representa o **Cérebro** do usuário, provocando a reflexão consciente de *"estou estragando o MEU cérebro"*. A inspiração de categoria é **Brainrot: Screen Time Control**, mas nome, personagem, textos e recursos visuais são próprios e em português brasileiro. O foco de lançamento é **iPhone**. Flutter foi escolhido para compartilhar a interface com uma futura versão Android; os recursos de controle do sistema continuam nativos em cada plataforma.

O usuário considera **Desvício** o nome atual. Monetização no iOS é uma possibilidade futura, ainda sem modelo definido ou implementado. Não inventar preços, assinatura ou paywall antes dessa decisão.

## Regras de produto atuais

- O usuário escolhe apps, categorias ou sites que mais o distraem. Só eles contam para a meta.
- Meta inicial sugerida: **120 minutos por dia**; opções atuais: 30, 60, 90, 120, 150, 180 e 240 minutos.
- O cérebro fica **Cansado** na metade da meta, **Fritando** no limite e **Pifou** após 30 minutos extras. No último estágio, os apps selecionados são bloqueados no iPhone para proteger a mente do usuário.
- Mecânica de ofensiva / sequência: o app contabiliza os dias consecutivos em que o cérebro não pifou (`streakDays` - "dias sem fritar"), exibindo um badge com fogo na tela inicial.
- Pausas de foco de **15, 25 ou 45 minutos** bloqueiam os apps escolhidos durante a sessão ("tempo de respiro"). O cérebro pode melhorar de humor ao concluí-la, exceto no estágio final do dia.
- O estado diário reinicia no dia seguinte. A linguagem é direta e acolhedora, incentivando o descanso sem punição excessiva.

Esses valores são hipóteses para validar com usuários. O app ainda não mostra os minutos exatos de uso diário; recebe eventos ao atingir os marcos (a extensão de relatório `DeviceActivityReport` foi analisada e planejada como próxima evolução para sanar essa lacuna). A pausa registra o tempo do cronômetro, sem verificar se a pessoa deixou de usar outros apps.

## O que já foi feito

- Repositório público: <https://github.com/EricGuerrize/Desvicio>, branch `main`.
- Primeiro app nativo SwiftUI criado; sua versão anterior permanece em `Desvicio/` e `Desvicio.xcodeproj` como referência.
- Migração da interface para Flutter em `lib/main.dart`, com onboarding, avatar vetorial do Cérebro (`BrainAvatar`), badge de ofensivas, tela inicial, foco, ajustes, política de privacidade e ação para apagar dados locais.
- Projeto iOS Flutter ativo em `ios/Runner.xcworkspace`. A ponte `ios/Runner/AppDelegate.swift` chama o modelo nativo em `ios/Runner/ScreenTime/`. A extensão `ios/DesvicioMonitor/` recebe os marcos de uso e aplica o bloqueio. A extensão `ios/DesvicioShield/` (`com.desvicio.app.shield`) personaliza a tela de bloqueio do sistema com os textos do Cérebro.
- O novo app mantém `com.desvicio.app` e o App Group `group.com.desvicio.app`, para preservar os dados locais da versão SwiftUI. A extensão de monitoramento usa `com.desvicio.app.monitor` e o escudo usa `com.desvicio.app.shield`.
- Projeto Android criado com a mesma interface e um canal Kotlin básico. **O Android ainda não mede nem bloqueia apps**; a interface deixa isso claro e impede iniciar o controle.
- Ícones próprios, manifestos de privacidade iOS e política de privacidade no repositório.
- Sem conta, login, servidor, anúncios, compras ou assinaturas. Portanto, a exclusão atual é de **dados locais**, não de conta.

## O que foi verificado

Na migração e evolução do Cérebro, com Flutter **3.47.6** e Xcode **27.0** neste Mac:

- `flutter analyze`: sem problemas (0 issues).
- `flutter test`: testes atualizados e passando (validação do novo fluxo de onboarding em 4 etapas, input com placeholder 'Meu Cérebro' vazio por padrão, e submissão com fallback).
- `flutter build ios --simulator --no-codesign`: compilou com sucesso incluindo `DesvicioMonitor` e `DesvicioShield`.
- `flutter build ios --release --no-codesign`: compilou com sucesso para iPhone (16.3MB), embutindo `PlugIns/DesvicioMonitor.appex` e `PlugIns/DesvicioShield.appex`.
- Onboarding inspirado em Brainrot implementado: diagnóstico de tempo diário com choque de impacto anual em dias, comparativo mental (Saudável vs Fritando), seleção rica de redes sociais/apps e sites (Instagram, TikTok, YouTube, X, Kwai, Reddit, Facebook, WhatsApp, Jogos, Streaming, Notícias, Apostas), adição de domínios customizados e batismo do cérebro com meta diária.
- Correção do bug de input e erro do teclado UIKit (`currentHandBias`): o campo de texto inicia vazio com `hintText: 'Meu Cérebro'`, evitando concatenação indesejada e adotando 'Meu Cérebro' como fallback se o usuário não digitar nada.
- Desbloqueio no simulador e seleção sem apps no iOS: a seleção nativa vazia no simulador ou sem permissões da Apple não impede mais o usuário de avançar e configurar o app.
- Ícone iOS de marketing exportado sem canal alfa.
- Análise estática do IPA do app de referência (Brainrot) concluída e documentada em `BRAINROT_ANALYSIS.md`.
- Conferência de build: não há `.ipa` do Desvício gerado. O build Release para iPhone continua sem assinatura (`code object is not signed at all`) e sem `embedded.mobileprovision`. Nada foi instalado em iPhone físico.

Essas verificações **não provam** que a autorização de Tempo de Uso, o monitoramento, o bloqueio ou a tela customizada do escudo funcionam em um iPhone real. O simulador não mostra a tela de escudo nativa. O build Release não foi assinado nem enviado à Apple. O Android não foi compilado: o Android SDK não estava instalado neste Mac no momento da migração.

## Onde estamos

O código Flutter iOS está no GitHub e compila. O passo mais importante agora é instalar e testar em **iPhone físico** com os recursos Family Controls e App Groups configurados em uma equipe Apple Developer. O usuário tem conta Apple Developer, mas informou que ainda **não aderiu ao programa pago**. Isso não impede continuar o desenvolvimento e usar o simulador; TestFlight e App Store exigem a adesão, e as capacidades avançadas podem exigir essa etapa para testes completos no aparelho.

O repositório está público. A política de privacidade tem URL pública no GitHub, mas **ainda falta um contato de suporte/privacidade e uma página pública de suporte**. Uma página estável no GitHub Pages é uma opção, mas o serviço de hospedagem não substitui o conteúdo exigido pela Apple.

## Próximos passos, em ordem sugerida

1. **Validar no iPhone real:** configurar equipe, identificadores, App Group e Family Controls nos alvos `Runner`, `DesvicioMonitor` e `DesvicioShield`. Registrar também `com.desvicio.app.shield`. Testar concessão, negação e revogação da autorização; seleção vazia; metade da meta; meta; 30 minutos extras; virada do dia; alteração da meta/seleção; pausas de foco; a tela do escudo no bloqueio diário e na pausa; desligamento e exclusão dos dados. Corrigir o que falhar.
2. **Preparar publicação iOS:** aderir ao Apple Developer Program quando for testar/distribuir com assinatura, solicitar **Family Controls (Distribution)** para o app, o monitor e o escudo, informar um contato e uma página pública de suporte, revisar política/declarações de privacidade, criar capturas reais e metadados da App Store. Ver [APP_STORE.md](APP_STORE.md).
3. **Validar o produto:** mostrar uso diário de forma permitida pelas APIs, melhorar a evolução do bichinho e avaliar com usuários os marcos, a experiência de bloqueio e as pausas. Histórico de sete dias, notificações, widgets e cosméticos ainda não foram implementados.
4. **Definir monetização:** decidir proposta gratuita/paga após validar o uso. Se houver compras, implementar e testar com as regras da App Store e atualizar a política de privacidade e os metadados.
5. **Android:** instalar Android SDK, compilar a base, implementar medição de uso e seleção com APIs Android, depois validar separadamente o comportamento de bloqueio e as políticas do Google Play. Não presumir que as APIs iOS tenham equivalente direto no Android.

## Limites e decisões importantes

- O app ativo é **Flutter + código nativo Swift no iOS**. Abrir `ios/Runner.xcworkspace`, não o projeto SwiftUI antigo, para trabalhar na versão atual.
- Não remover as extensões iOS. O monitor precisa executar quando o app principal não está aberto. O escudo só muda o visual da tela de bloqueio; sem a extensão de ação, o botão **Fechar** apenas dispensa essa tela. A interface Flutter conversa com Swift pelo canal `com.desvicio.app/control`.
- Não mudar `com.desvicio.app`, `com.desvicio.app.monitor`, `com.desvicio.app.shield` ou `group.com.desvicio.app` sem planejar migração dos dados e configuração no portal Apple.
- Não afirmar que o app está pronto para a App Store sem teste assinado em aparelho, capacidade de distribuição aprovada e metadados/suporte completos.
- Se contas forem adicionadas, revisar a exigência de entrada equivalente para login social e implementar exclusão de conta dentro do app. O estado atual sem contas não precisa de botões falsos de login/exclusão.
- Manter [README.md](README.md), este arquivo e [APP_STORE.md](APP_STORE.md) atualizados quando o estado mudar. Registrar o que foi testado e o que continua apenas planejado.

## Comandos úteis

```sh
flutter pub get
flutter analyze
flutter test
flutter build ios --simulator --no-codesign
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace
```

No Xcode, selecionar o esquema **Runner** e um simulador de iPhone; pressionar **⌘R**. Para testar bloqueio real, selecionar um iPhone físico com assinatura e capacidades configuradas. O projeto Flutter no Android ainda precisa do SDK Android local para compilar.
