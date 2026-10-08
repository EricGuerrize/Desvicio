# Contexto do projeto Desvício

Atualizado em 8 de outubro de 2026. Este arquivo é o ponto de partida para uma nova conversa no terminal ou com outra IA. Leia também [README.md](README.md), [APP_STORE.md](APP_STORE.md) e [PRIVACY.md](PRIVACY.md).

## Objetivo

Criar um app brasileiro de cuidado com o tempo de tela, com um bichinho virtual que reage ao uso de apps escolhidos pelo usuário. A inspiração de categoria é **Brainrot: Screen Time Control** e a dinâmica de cuidado lembra um bichinho virtual, mas nome, personagem, textos e recursos visuais devem ser próprios. O foco de lançamento é **iPhone**. Flutter foi escolhido para compartilhar a interface com uma futura versão Android; os recursos de controle do sistema continuam nativos em cada plataforma.

O usuário considera **Desvício** o nome atual. Monetização no iOS é uma possibilidade futura, ainda sem modelo definido ou implementado. Não inventar preços, assinatura ou paywall antes dessa decisão.

## Regras de produto atuais

- O usuário escolhe apps, categorias ou sites que mais o distraem. Só eles contam para a meta.
- Meta inicial sugerida: **120 minutos por dia**; opções atuais: 30, 60, 90, 120, 150, 180 e 240 minutos.
- O bichinho fica **cansadinho** na metade da meta, **dodói** no limite e **fantasminha** após 30 minutos extras. No último estágio, os apps selecionados são bloqueados no iPhone.
- Pausas de foco de **15, 25 ou 45 minutos** bloqueiam os apps escolhidos durante a sessão. O bichinho pode melhorar ao concluí-la, exceto no estágio final do dia.
- O estado diário reinicia no dia seguinte. A linguagem deve ser acolhedora, sem punição excessiva.

Esses valores são hipóteses para validar com usuários. O app ainda não mostra os minutos exatos de uso diário; recebe eventos ao atingir os marcos. A pausa registra o tempo do cronômetro, sem verificar se a pessoa deixou de usar outros apps.

## O que já foi feito

- Repositório público: <https://github.com/EricGuerrize/Desvicio>, branch `main`.
- Primeiro app nativo SwiftUI criado; sua versão anterior permanece em `Desvicio/` e `Desvicio.xcodeproj` como referência.
- Migração da interface para Flutter em `lib/main.dart`, com onboarding, bichinho, tela inicial, foco, ajustes, política de privacidade e ação para apagar dados locais.
- Projeto iOS Flutter ativo em `ios/Runner.xcworkspace`. A ponte `ios/Runner/AppDelegate.swift` chama o modelo nativo em `ios/Runner/ScreenTime/`. A extensão `ios/DesvicioMonitor/` recebe os marcos de uso e aplica o bloqueio.
- O novo app mantém `com.desvicio.app` e o App Group `group.com.desvicio.app`, para preservar os dados locais da versão SwiftUI. A extensão usa `com.desvicio.app.monitor`.
- Projeto Android criado com a mesma interface e um canal Kotlin básico. **O Android ainda não mede nem bloqueia apps**; a interface deixa isso claro e impede iniciar o controle.
- Ícones próprios, manifestos de privacidade iOS e política de privacidade no repositório.
- Sem conta, login, servidor, anúncios, compras ou assinaturas. Portanto, a exclusão atual é de **dados locais**, não de conta.

## O que foi verificado

Na migração Flutter, com Flutter **3.47.6** e Xcode **27.0** neste Mac:

- `flutter analyze`: sem problemas.
- `flutter test`: teste da tela inicial passou.
- `flutter build ios --simulator --no-codesign`: compilou.
- App e extensão instalados e app aberto em simulador iPhone 17 com iOS 27.0; a tela inicial foi visualizada.
- `flutter build ios --release --no-codesign`: compilou para iPhone.
- Ícone iOS de marketing exportado sem canal alfa.

Essas verificações **não provam** que a autorização de Tempo de Uso, o monitoramento e o bloqueio funcionam em um iPhone real. O build Release não foi assinado nem enviado à Apple. O Android não foi compilado: o Android SDK não estava instalado neste Mac no momento da migração.

## Onde estamos

O código Flutter iOS está no GitHub e compila. O passo mais importante agora é instalar e testar em **iPhone físico** com os recursos Family Controls e App Groups configurados em uma equipe Apple Developer. O usuário tem conta Apple Developer, mas informou que ainda **não aderiu ao programa pago**. Isso não impede continuar o desenvolvimento e usar o simulador; TestFlight e App Store exigem a adesão, e as capacidades avançadas podem exigir essa etapa para testes completos no aparelho.

O repositório está público. A política de privacidade tem URL pública no GitHub, mas **ainda falta um contato de suporte/privacidade e uma página pública de suporte**. Uma página estável no GitHub Pages é uma opção, mas o serviço de hospedagem não substitui o conteúdo exigido pela Apple.

## Próximos passos, em ordem sugerida

1. **Validar no iPhone real:** configurar equipe, identificadores, App Group e Family Controls nos alvos `Runner` e `DesvicioMonitor`. Testar concessão, negação e revogação da autorização; seleção vazia; metade da meta; meta; 30 minutos extras; virada do dia; alteração da meta/seleção; pausas de foco; desligamento e exclusão dos dados. Corrigir o que falhar.
2. **Preparar publicação iOS:** aderir ao Apple Developer Program quando for testar/distribuir com assinatura, solicitar **Family Controls (Distribution)** para app e extensão, informar um contato e uma página pública de suporte, revisar política/declarações de privacidade, criar capturas reais e metadados da App Store. Ver [APP_STORE.md](APP_STORE.md).
3. **Validar o produto:** mostrar uso diário de forma permitida pelas APIs, melhorar a evolução do bichinho e avaliar com usuários os marcos, a experiência de bloqueio e as pausas. Histórico de sete dias, notificações, widgets e cosméticos ainda não foram implementados.
4. **Definir monetização:** decidir proposta gratuita/paga após validar o uso. Se houver compras, implementar e testar com as regras da App Store e atualizar a política de privacidade e os metadados.
5. **Android:** instalar Android SDK, compilar a base, implementar medição de uso e seleção com APIs Android, depois validar separadamente o comportamento de bloqueio e as políticas do Google Play. Não presumir que as APIs iOS tenham equivalente direto no Android.

## Limites e decisões importantes

- O app ativo é **Flutter + código nativo Swift no iOS**. Abrir `ios/Runner.xcworkspace`, não o projeto SwiftUI antigo, para trabalhar na versão atual.
- Não remover a extensão iOS: ela precisa executar quando o app principal não está aberto. A interface Flutter conversa com Swift pelo canal `com.desvicio.app/control`.
- Não mudar `com.desvicio.app`, `com.desvicio.app.monitor` ou `group.com.desvicio.app` sem planejar migração dos dados e configuração no portal Apple.
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
