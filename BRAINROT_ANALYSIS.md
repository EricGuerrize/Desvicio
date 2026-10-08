# Análise Técnica: Brainrot Screen Time Control vs. Desvício

Data da análise: 8 de outubro de 2026  
Artefato analisado: `/Users/eric/Downloads/brainrot-ipa/Brainrot.ipa`  
App Store ID: `6744338972` | Bundle ID: `smobiz.brainrot` | Versão: `2.0.10` (Build `4`) | iOS Mínimo: `17.6`

---

## 1. Inventário

### Layout do Bundle (`Payload/brainrot.app`)
- **Executável Principal:** `brainrot` (Mach-O 64-bit arm64).
- **Diretório de Extensões 1 (`PlugIns/`):** Contém 5 extensões (`.appex`):
  - `brainrotDeviceActivityMonitor.appex`
  - `brainrotNotificationServiceExtension.appex`
  - `brainrotShieldAction.appex`
  - `brainrotShieldConfiguration.appex`
  - `brainrotWidgetExtension.appex`
- **Diretório de Extensões 2 (`Extensions/`):** Contém 1 extensão (`.appex`):
  - `brainrotDeviceActivityReport.appex`
- **Diretório de Frameworks Dinâmicos (`Frameworks/`):** 22 frameworks/dylibs embutidos.
- **Modelos e Dados Estruturados:**
  - Core Data compilado: `BrainRot.momd/BrainRot.mom`.
  - App Intents metadata: `PlugIns/brainrotWidgetExtension.appex/Metadata.appintents/extract.actionsdata`.
- **Recursos Visuais e de Mídia:**
  - 47+ animações Lottie (`.json`): séries de saúde (`brain-health-0.json` a `brain-health-100-*.json`), humores (`brain-happy.json`, `brain-tired.json`, `brain-fever.json`, `brain-angry.json`), perfis de uso (`brain-profile-*.json`), estados de rotina e streaks (`brain-streak-*.json`). Arquivos replicados também dentro de `brainrotDeviceActivityReport.appex`.
  - Vídeos: `intro_video.mp4` e `rotting_animation.mp4`.
  - Tipografia: Família `Rubik` (`Rubik-Regular.ttf`, `Rubik-Medium.ttf`, `Rubik-SemiBold.ttf`, `Rubik-Bold.ttf`, `Rubik-ExtraBold.ttf`, `Rubik-Black.ttf`).
  - Catálogo de ativos compilado: `Assets.car` no app e nas extensões.
- **Bundles Auxiliares de Terceiros:**
  - `SuperwallKit_SuperwallKit.bundle` (contendo `SuperwallKit_Model.momd` Core Data próprio).
  - `Mixpanel_Mixpanel.bundle`.
  - `Lottie_Lottie.bundle`.
  - Bundles de infraestrutura Google/Firebase/gRPC (`abseil_abslWrapper.bundle`, `leveldb_leveldb.bundle`, `nanopb_nanopb.bundle`, etc.).
- **Arquivos de Configuração de Terceiros Presentes:**
  - `GoogleService-Info.plist`, `Secrets.plist` e `RemoteConfigDefaults.plist` (presentes no bundle).

### Identificadores e Versões
- **App Principal:** `smobiz.brainrot` (Versão `2.0.10`, Build `4`, Team ID: `Z2VQMM6Y6K`).
- **`brainrotDeviceActivityMonitor.appex`:** `smobiz.brainrot.brainrotDeviceActivityMonitor` (`2.0.10` / `4`).
- **`brainrotNotificationServiceExtension.appex`:** `smobiz.brainrot.brainrotNotificationServiceExtension` (`2.0.10` / `4`).
- **`brainrotShieldAction.appex`:** `smobiz.brainrot.brainrotShieldAction` (`2.0.10` / `4`).
- **`brainrotShieldConfiguration.appex`:** `smobiz.brainrot.brainrotShieldConfiguration` (`2.0.10` / `4`).
- **`brainrotWidgetExtension.appex`:** `smobiz.brainrot.brainrotWidget` (`2.0.10` / `4`).
- **`brainrotDeviceActivityReport.appex`:** `smobiz.brainrot.brainrotDeviceActivityReport` (`2.0.10` / `4`).

### Configurações Relevantes do Info.plist (`Payload/brainrot.app/Info.plist`)
- **Usage Strings:**
  - `NSCameraUsageDescription`: *"Mirror mode helps you reflect before opening blocked apps"*
  - `NSUserTrackingUsageDescription`: *"It will help us provide you a more personalized experience and relevant content."*
- **URL Schemes:**
  - `brainrot` (identificador `com.brainrot.deeplink`)
  - `fb1500976564241605` (Facebook SDK)
- **Background Modes:** `fetch`, `remote-notification`.
- **Tarefas de Background (`BGTaskSchedulerPermittedIdentifiers`):** `com.brainrot.snooze-rescue`.
- **Suporte a Live Activities:** `NSSupportsLiveActivities: true`.
- **Chave de App Group compartilhada para OneSignal:** `OneSignal_app_groups_key: group.com.brainrot.shared`.

### Entitlements por Alvo (Extraídos da Assinatura de Código)
- **`brainrot` (App Principal):**
  - `application-identifier`: `Z2VQMM6Y6K.smobiz.brainrot`
  - `com.apple.developer.family-controls`: `true`
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`
  - `com.apple.developer.usernotifications.time-sensitive`: `true`
  - `aps-environment`: `production`
- **`brainrotDeviceActivityMonitor.appex`:**
  - `com.apple.developer.family-controls`: `true`
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`
- **`brainrotNotificationServiceExtension.appex`:**
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`
- **`brainrotShieldAction.appex`:**
  - `com.apple.developer.family-controls`: `true`
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`
  - `com.apple.developer.usernotifications.time-sensitive`: `true`
- **`brainrotShieldConfiguration.appex`:**
  - `com.apple.developer.family-controls`: `true`
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`
- **`brainrotWidgetExtension.appex`:**
  - `com.apple.developer.family-controls`: `true`
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`
- **`brainrotDeviceActivityReport.appex`:**
  - `com.apple.developer.family-controls`: `true`
  - `com.apple.security.application-groups`: `[group.com.brainrot.shared]`

---

## 2. Screen Time API: Frameworks, Linkage e Extension Points

| Framework Apple | Binários Linkados (`otool -L`) | Extension Point Associado | Presença Física / Entitlement |
| :--- | :--- | :--- | :--- |
| **`FamilyControls`** | `brainrot`, `brainrotDeviceActivityMonitor`, `brainrotWidgetExtension`, `brainrotDeviceActivityReport` | N/A | Framework do sistema; Entitlement `com.apple.developer.family-controls` ativo em 6 alvos. |
| **`DeviceActivity`** | `brainrot`, `brainrotDeviceActivityMonitor`, `brainrotWidgetExtension`, `brainrotDeviceActivityReport` | `com.apple.deviceactivity.monitor-extension` (`brainrotDeviceActivityMonitor.appex`) | Framework do sistema linkado diretamente. |
| **`ManagedSettings`** | `brainrot`, `brainrotDeviceActivityMonitor`, `brainrotShieldAction`, `brainrotShieldConfiguration`, `brainrotWidgetExtension`, `brainrotDeviceActivityReport` | `com.apple.ManagedSettings.shield-action-service` (`brainrotShieldAction.appex`) | Framework do sistema linkado diretamente. |
| **`ManagedSettingsUI`** | `brainrotShieldConfiguration` | `com.apple.ManagedSettingsUI.shield-configuration-service` (`brainrotShieldConfiguration.appex`) | Framework do sistema linkado apenas na extensão de configuração de escudo. |
| **`_DeviceActivity_SwiftUI`** | `brainrot`, `brainrotDeviceActivityReport` | `com.apple.deviceactivityui.report-extension` (`brainrotDeviceActivityReport.appex`) | Framework privado/público de interface linkado no app e no relatório. |

---

## 3. Mapeamento das Cinco Áreas Funcionais

### 1. Bloqueio de Apps e Sites
- **Status:** **Evidência**.
- **Fundamentação:**
  - `FamilyControls` e `ManagedSettings` linkados no app e em 5 extensões.
  - Presença de `brainrotShieldConfiguration.appex` (`com.apple.ManagedSettingsUI.shield-configuration-service`), permitindo customizar o visual da tela de bloqueio (título, subtítulo, botões e ícone do sistema).
  - Presença de `brainrotShieldAction.appex` (`com.apple.ManagedSettings.shield-action-service`), interceptando cliques nos botões do bloqueio.
  - `NSCameraUsageDescription` no `Info.plist` indicando intervenção por vídeo/espelho (*"Mirror mode helps you reflect before opening blocked apps"*).
  - `BGTaskSchedulerPermittedIdentifiers` configurado com `com.brainrot.snooze-rescue` para regulação de desbloqueio temporário em segundo plano.

### 2. Focus Timer / Pomodoro
- **Status:** **Evidência**.
- **Fundamentação:**
  - Entidades no Core Data compilado (`BrainRot.mom`):
    - `FocusSession`: atributos `startedAt`, `endedAt`, `durationMinutes`, `healthRegained`.
    - `FocusStats`: atributos `totalSessions`, `totalFocusMinutes`, `longestSessionMinutes`, `longestSessionDate`, `bestDayMinutes`, `bestDayDate`.
  - App Intents exportados em `extract.actionsdata` na extensão de widget:
    - `StartFocusIntent`
    - `SelectDurationIntent` (parâmetro `minutes`)
    - `CancelFocusIntent`
    - `FocusConfigurationIntent`
  - `ActivityKit` e `NSSupportsLiveActivities: true` no app e na extensão de widget para exibição de timer na Dynamic Island e Tela Bloqueada.

### 3. Schedules (Bedtime, Manhã, Reuniões ou Equivalentes)
- **Status:** **Não encontrado no IPA**.
- **Fundamentação:**
  - O modelo Core Data contém apenas meta diária agregada (`UserPreferences.goalScreenTimeHours` e `UserPreferences.currentScreenTimeHours`) e sessões sob demanda (`FocusSession`).
  - Não existem tabelas, entidades, strings ou tarefas em segundo plano para horários fixos de dormir/acordar ou rotinas personalizadas por horário no bundle.

### 4. Avatar / Cérebro que Muda com o Uso
- **Status:** **Evidência**.
- **Fundamentação:**
  - 47+ arquivos Lottie detalhando múltiplos níveis de saúde (`brain-health-0.json`, `brain-health-20.json`, `brain-health-40.json`, `brain-health-60.json`, `brain-health-80.json`, `brain-health-100-*.json`), humores (`brain-happy`, `brain-tired`, `brain-fever`, `brain-sickening`, `brain-angry`, `brain-void`, `brain-zonedout`, `brain-sleepy`) e streaks (`brain-streak-1.json`, `brain-streak-2.json`, `brain-streak-3.json`).
  - Entidade `BrainState` no Core Data (`brainHealth`, `screenTimeMinutes`, `snoozeCount`, `date`).
  - Animações replicadas dentro da extensão `brainrotDeviceActivityReport.appex`, indicando renderização direta do avatar no contexto do relatório.

### 5. Insights / Relatório de Uso
- **Status:** **Evidência**.
- **Fundamentação:**
  - Extensão dedicada `Extensions/brainrotDeviceActivityReport.appex` configurada com `EXAppExtensionAttributes` -> `EXExtensionPointIdentifier = com.apple.deviceactivityui.report-extension`.
  - Frameworks `_DeviceActivity_SwiftUI` e `DeviceActivity` linkados no app e na extensão para geração dos gráficos de tempo de tela sob as regras de privacidade do iOS.

---

## 4. Tabela Resumo

| Categoria | Identificador / Nome | Detalhes no Bundle do Brainrot |
| :--- | :--- | :--- |
| **Frameworks de Terceiros** | OneSignal (8 frameworks) | `OneSignalFramework`, `OneSignalNotifications`, `OneSignalInAppMessages`, `OneSignalLiveActivities`, `OneSignalExtension`, `OneSignalCore`, `OneSignalOSCore`, `OneSignalOutcomes` |
| | Firebase & Google (6 frameworks) | `FirebaseAnalytics`, `FirebaseFirestoreInternal`, `GoogleAppMeasurement`, `GoogleAppMeasurementIdentitySupport`, `GoogleAdsOnDeviceConversion`, bundles de Core e Remote Config |
| | Facebook SDK (3 frameworks) | `FBSDKCoreKit`, `FBSDKCoreKit_Basics`, `FBAEMKit` |
| | Superwall Paywall | `SuperwallKit_SuperwallKit.bundle` (com Core Data `SuperwallKit_Model.momd`) |
| | Mixpanel | `Mixpanel_Mixpanel.bundle` |
| | Appstack SDK | `AppstackSDK.framework` (atribuição de anúncios) |
| | gRPC / Abseil / Protobuf | `grpc.framework`, `grpcpp.framework`, `absl.framework`, `openssl_grpc.framework` |
| **Permissões (Usage Strings)** | `NSCameraUsageDescription` | *"Mirror mode helps you reflect before opening blocked apps"* |
| | `NSUserTrackingUsageDescription` | *"It will help us provide you a more personalized experience and relevant content."* |
| **Background Modes** | `fetch`, `remote-notification` | Atualização em segundo plano e notificações push |
| **Tarefas de Background** | `BGTaskSchedulerPermittedIdentifiers` | `com.brainrot.snooze-rescue` |
| **App Extensions** | `brainrotDeviceActivityMonitor` | `NSExtensionPointIdentifier`: `com.apple.deviceactivity.monitor-extension` |
| | `brainrotShieldConfiguration` | `NSExtensionPointIdentifier`: `com.apple.ManagedSettingsUI.shield-configuration-service` |
| | `brainrotShieldAction` | `NSExtensionPointIdentifier`: `com.apple.ManagedSettings.shield-action-service` |
| | `brainrotWidgetExtension` | `NSExtensionPointIdentifier`: `com.apple.widgetkit-extension` |
| | `brainrotNotificationServiceExtension` | `NSExtensionPointIdentifier`: `com.apple.usernotifications.service` |
| | `brainrotDeviceActivityReport` | `EXExtensionPointIdentifier`: `com.apple.deviceactivityui.report-extension` |

---

## 5. Análise de Binários e Criptografia FairPlay

- Todos os binários executáveis (`brainrot` e os executáveis das 6 extensões) apresentam `LC_ENCRYPTION_INFO_64` com **`cryptid 1`**, indicando proteção criptográfica FairPlay da App Store.
- O segmento `__TEXT` está criptografado pelo DRM da Apple. Em conformidade com as restrições éticas e de engenharia reversa, o código de máquina não foi descriptografado nem submetido a disassembly.
- Todas as conclusões deste relatório fundamentam-se exclusivamente em metadados desprotegidos: cabeçalhos Mach-O, load commands (`LC_LOAD_DYLIB`), assinaturas de código e entitlements embutidos, `Info.plist`, schemas compilados Core Data, App Intents actionsdata, bundles de assets e arquivos de animação.

---

## 6. Comparativo com o Desvício Atual e Propostas de Melhoria

### Estado Atual do Desvício
- **Interface e Ponte:** Flutter na raiz com ponte nativa em [AppDelegate.swift](file:///Users/eric/Desktop/desvicio/ios/Runner/AppDelegate.swift) chamando [DesvicioModel.swift](file:///Users/eric/Desktop/desvicio/ios/Runner/ScreenTime/DesvicioModel.swift) e [SharedState.swift](file:///Users/eric/Desktop/desvicio/ios/Runner/ScreenTime/SharedState.swift).
- **Extensões Ativas:** Apenas uma extensão de monitoramento em [DesvicioMonitor.swift](file:///Users/eric/Desktop/desvicio/ios/DesvicioMonitor/DesvicioMonitor.swift) (`com.apple.deviceactivity.monitor-extension`).
- **Bloqueio:** Aplicado via `ManagedSettingsStore()` quando o bichinho atinge o humor `.ghost` (limite diário + 30 minutos extras) ou durante pausas de foco ativas.
- **Limitações Conhecidas:** A tela de bloqueio é a cinza genérica da Apple; o app não reporta minutos consumidos exatos (apenas eventos de 50%, 100% e +30 min); não há widget, Live Activity nem interação direta no escudo.

### Melhorias Propostas

#### 1. Customização Visual da Tela de Bloqueio (Shield Configuration Extension)
- **Prioridade:** **P1**
- **Dificuldade:** **Baixa**
- **O que o Desvício já tem:** O [DesvicioModel.swift](file:///Users/eric/Desktop/desvicio/ios/Runner/ScreenTime/DesvicioModel.swift) e o [DesvicioMonitor.swift](file:///Users/eric/Desktop/desvicio/ios/DesvicioMonitor/DesvicioMonitor.swift) ativam o shield do sistema (`store.shield.applications`).
- **Buraco Concreto:** O usuário é recebido pela tela genérica cinza da Apple ("Limite de tempo"). Não há menção ao bichinho virtual ("Pingo"), sua imagem ou a mensagem acolhedora ("Ainda dá tempo de cuidar de mim").
- **Solução sustentada pelo Brainrot:** Criar uma extensão `DesvicioShieldConfiguration` (`com.apple.ManagedSettingsUI.shield-configuration-service`) para customizar título, mensagem acolhedora, cores e ícone do Pingo no bloqueio do sistema.

#### 2. Exibição de Minutos Reais Consumidos (Device Activity Report Extension)
- **Prioridade:** **P1**
- **Dificuldade:** **Média**
- **O que o Desvício já tem:** O app calcula metas e monitora limites, mas conforme registrado em [PROJECT_CONTEXT.md](file:///Users/eric/Desktop/desvicio/PROJECT_CONTEXT.md#L19), *"O app ainda não mostra os minutos exatos de uso diário; recebe eventos ao atingir os marcos"*.
- **Buraco Concreto:** Sem a extensão de relatório, o app principal não tem permissão da sandbox do iOS para ler o tempo consumido pelo usuário nos apps restritos.
- **Solução sustentada pelo Brainrot:** Criar uma extensão `DesvicioDeviceActivityReport` (`com.apple.deviceactivityui.report-extension`) linkada com `_DeviceActivity_SwiftUI`, devolvendo uma view SwiftUI com o tempo real consumido para ser apresentada dentro do fluxo do app.

#### 3. Interceptação de Ações no Bloqueio para Pausas de Reflexão (Shield Action Extension)
- **Prioridade:** **P2**
- **Dificuldade:** **Média**
- **O que o Desvício já tem:** Bloqueio passivo sem resposta a eventos de clique na tela de bloqueio.
- **Buraco Concreto:** Quando o usuário se depara com o app bloqueado, o botão padrão apenas fecha o app. Não há como oferecer uma saída consciente (ex.: abrir o Desvício para fazer uma sessão de respiração/foco ou pedir 5 minutos de emergência).
- **Solução sustentada pelo Brainrot:** Implementar uma extensão `DesvicioShieldAction` (`com.apple.ManagedSettings.shield-action-service`) que receba o toque nos botões do Shield e permita redirecionar o usuário para o app ou iniciar um adiamento temporário controlado.

#### 4. Widget Interativo e Live Activity para Sessão de Foco
- **Prioridade:** **P2**
- **Dificuldade:** **Média**
- **O que o Desvício já tem:** Foco cronometrado (15, 25, 45 min) em [DesvicioModel.swift](file:///Users/eric/Desktop/desvicio/ios/Runner/ScreenTime/DesvicioModel.swift#L165-L209) que bloqueia os apps durante o período.
- **Buraco Concreto:** O usuário só acompanha a sessão de foco mantendo o app Desvício aberto ou reabrindo manualmente. Não há visibilidade do timer na Tela Bloqueada, na Dynamic Island ou na Tela de Início.
- **Solução sustentada pelo Brainrot:** Implementar uma extensão WidgetKit com suporte a Live Activities (`ActivityKit`) e App Intents (`AppIntents`), permitindo acompanhar e controlar sessões de foco diretamente do sistema.

---

## 7. Viabilidade Técnica, Entitlements e Diretrizes

- **Uso Exclusivo de APIs Públicas:** Todas as quatro melhorias utilizam frameworks públicos documentados pela Apple (`ManagedSettingsUI`, `DeviceActivityReport`, `ManagedSettings`, `WidgetKit`, `ActivityKit`, `AppIntents`). Nenhuma depende de APIs privadas ou comportamentos não documentados.
- **Entitlements Exigidos por Alvo:**
  - **Extensão Shield Configuration:**
    - `com.apple.developer.family-controls`: `true`
    - `com.apple.security.application-groups`: `[group.com.desvicio.app]`
  - **Extensão Device Activity Report:**
    - `com.apple.developer.family-controls`: `true`
    - `com.apple.security.application-groups`: `[group.com.desvicio.app]`
  - **Extensão Shield Action:**
    - `com.apple.developer.family-controls`: `true`
    - `com.apple.security.application-groups`: `[group.com.desvicio.app]`
  - **Extensão Widget / Live Activity:**
    - `com.apple.security.application-groups`: `[group.com.desvicio.app]`
    - `com.apple.developer.family-controls`: `true` (apenas se manipular tokens de seleção de apps diretamente).
- **Arquitetura do Produto Preservada:**
  - Nenhuma sugestão introduz login, cadastro, servidores, anúncios ou monetização prematura.
  - O armazenamento permanece totalmente local no App Group compartilhado (`group.com.desvicio.app`).
- **Atenção Regulatória da App Store:**
  - Cada nova extensão que utilize o framework Family Controls demandará autorização prévia da Apple para a capacidade **Family Controls (Distribution)** antes do arquivamento do build de distribuição.
  - O app continuará dependendo de validação manual completa em iPhone físico com perfis de desenvolvimento provisionados antes de qualquer submissão.
