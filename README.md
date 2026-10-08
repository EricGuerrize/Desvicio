# Desvício

Um bichinho virtual que reage ao tempo gasto nos aplicativos que você escolheu controlar. A interface agora é feita em **Flutter**, com foco inicial no iPhone. O monitoramento e o bloqueio no iOS usam as APIs nativas **Family Controls**, **Device Activity** e **Managed Settings**.

## Estado do projeto

- **iPhone:** interface Flutter, seleção de apps, meta diária, estados do bichinho, bloqueio após 30 minutos extras, pausas de foco e exclusão dos dados locais. A extensão nativa em Swift continua responsável pelos marcos de uso e pelo bloqueio. O app Flutter usa o mesmo identificador e App Group da versão SwiftUI anterior para conservar os dados locais.
- **Android:** projeto Flutter criado e interface compartilhada. O controle de outros apps ainda não está implementado. O app informa isso explicitamente; a versão Android ainda não deve ser publicada.
- **Contas e pagamentos:** não existem nesta versão. Uma eventual assinatura será planejada após validar o fluxo principal no iPhone.

O código anterior em SwiftUI permanece em `Desvicio/` e `Desvicio.xcodeproj` como referência da migração. O projeto ativo é o Flutter na raiz do repositório.

## Rodar e visualizar no Xcode

1. Instale [Flutter](https://docs.flutter.dev/get-started/install/macos) e Xcode. Neste Mac, Flutter 3.47.6 está instalado.
2. Na raiz do repositório, rode `flutter pub get` e `flutter build ios --config-only`.
3. Abra **`ios/Runner.xcworkspace`** no Xcode, selecione o esquema **Runner** e um simulador de iPhone, então pressione **⌘R**. Para iniciar pelo terminal, use `flutter run -d <id-do-simulador>`.
4. Para editar a interface, altere `lib/main.dart`. O Xcode compila e executa o app, mas a edição visual Flutter é mais prática com hot reload pelo Flutter ou pela extensão Flutter de VS Code/Android Studio.

O alvo mínimo do iOS é 17.4. O simulador verifica interface e integração, mas **não valida o bloqueio real** de aplicativos. Isso precisa de teste em iPhone físico.

## Estrutura

- `lib/main.dart`: interface, bichinho e comunicação com as plataformas.
- `ios/Runner/AppDelegate.swift`: ponte entre Flutter e o Tempo de Uso nativo.
- `ios/Runner/ScreenTime/`: estado e lógica de monitoramento no iPhone.
- `ios/DesvicioMonitor/`: extensão que recebe os marcos de uso e altera o estado do bichinho.
- `android/`: base Android. O controle de uso ainda requer implementação e validação próprias.
- `PRIVACY.md` e `APP_STORE.md`: privacidade e preparação para publicação.

## Para testar no iPhone

Configure uma equipe Apple Developer no Xcode para **Runner** e **DesvicioMonitor**, registre `com.desvicio.app`, `com.desvicio.app.monitor` e o App Group `group.com.desvicio.app`, e habilite Family Controls e App Groups para os alvos. A distribuição exige a aprovação da Apple para **Family Controls (Distribution)** no app e na extensão. A adesão paga ao Apple Developer Program é necessária para TestFlight e App Store e pode ser necessária para testar as capacidades avançadas no aparelho.

O app não exige login. A opção **Ajustes → Apagar meus dados deste iPhone** interrompe o controle e remove os dados locais. Se contas forem adicionadas no futuro, serão necessárias opções de entrada equivalentes às exigidas pela Apple e exclusão de conta dentro do app.

## Regras atuais do bichinho

Meta sugerida de 120 minutos nos apps escolhidos. O bichinho fica cansado na metade, dodói no limite e vira fantasminha após mais 30 minutos, quando os apps são bloqueados. Pausas de foco de 15, 25 ou 45 minutos bloqueiam os apps escolhidos durante a sessão. O estado recomeça no dia seguinte.

Esses valores são hipóteses de produto. O personagem e a identidade visual são originais.
