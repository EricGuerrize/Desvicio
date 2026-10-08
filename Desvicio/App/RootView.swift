import SwiftUI
import FamilyControls

struct RootView: View {
    @EnvironmentObject private var model: DesvicioModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if model.isConfigured {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .tint(Theme.moss)
        .background(Theme.cream.ignoresSafeArea())
        .alert("Ops!", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("Entendi", role: .cancel) { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.refresh() }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var model: DesvicioModel
    @State private var name = ""
    @State private var isPickerPresented = false
    @State private var showPrivacy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("desvício")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.moss)

                VStack(alignment: .leading, spacing: 9) {
                    Text("Menos scroll.\nMais vida.")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.ink)
                    Text("Seu cérebro sente quando você se perde na tela — e descansa a cada pausa.")
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.ink.opacity(0.7))
                }

                PetView(mood: .happy, size: 190)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)

                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Dê um nome ao seu cérebro", systemImage: "brain.head.profile")
                            .font(.headline)
                        TextField("Meu Cérebro", text: $name)
                            .textInputAutocapitalization(.words)
                            .padding(14)
                            .background(Theme.cream, in: RoundedRectangle(cornerRadius: 14))
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Escolha o que te distrai", systemImage: "apps.iphone")
                            .font(.headline)
                        Text("Selecione apps, categorias ou sites. Só esse uso conta para a meta.")
                            .foregroundStyle(.secondary)
                        Button {
                            isPickerPresented = true
                        } label: {
                            HStack {
                                Text(model.selectedCount == 0
                                     ? "Escolher apps e sites"
                                     : "\(model.selectedCount) selecionado(s)")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Sua meta por dia", systemImage: "hourglass")
                            .font(.headline)
                        Picker("Tempo", selection: $model.limitMinutes) {
                            ForEach([30, 60, 90, 120, 150, 180, 240], id: \.self) { minutes in
                                Text(minutes < 60 ? "\(minutes) min" : "\(minutes / 60)h \(minutes % 60 == 0 ? "" : "\(minutes % 60)min")")
                                    .tag(minutes)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Button {
                    let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    model.saveName(finalName.isEmpty ? "Meu Cérebro" : finalName)
                    model.configure()
                } label: {
                    HStack {
                        Spacer()
                        if model.isBusy { ProgressView().tint(.white) }
                        Text("Começar a cuidar")
                        Spacer()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(model.isBusy)

                Text("O iPhone pedirá sua autorização para controlar os apps escolhidos. Seus dados de uso ficam no aparelho.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Política de privacidade") { showPrivacy = true }
                    .font(.footnote)
            }
            .padding(24)
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
        .onChange(of: model.selection) { _, _ in model.saveSelection() }
        .sheet(isPresented: $showPrivacy) { PrivacyView() }
    }
}

struct HomeView: View {
    @EnvironmentObject private var model: DesvicioModel
    @State private var showSettings = false
    @State private var showFocus = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("desvício")
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.moss)
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.ink)
                            .frame(width: 44, height: 44)
                            .background(.white, in: Circle())
                    }
                    .accessibilityLabel("Ajustes")
                }

                VStack(spacing: 10) {
                    Text("Esse é o \(model.pet.name)")
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.ink)
                    PetView(mood: model.pet.mood, size: 240)
                    Text(model.pet.mood.title)
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                    Text(model.pet.mood.message)
                        .font(.body)
                        .foregroundStyle(Theme.ink.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.mint.opacity(0.45), in: RoundedRectangle(cornerRadius: 34))

                Card {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("Sua meta de hoje", systemImage: "hourglass")
                            .font(.headline)
                        Text("\(model.limitMinutes) minutos nos apps escolhidos")
                            .foregroundStyle(Theme.ink.opacity(0.75))
                        Text("Ele fica dodói no limite. Após 30 minutos extras, vira fantasminha e os apps são bloqueados.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("Tempo de cuidado", systemImage: "sparkles")
                            .font(.headline)
                        Text("\(model.pet.focusMinutes) min de foco hoje")
                            .foregroundStyle(Theme.ink.opacity(0.75))
                    }
                }

                Button("Fazer uma pausa de foco") { showFocus = true }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
        }
        .onAppear { model.refresh() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showFocus) { FocusView() }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var model: DesvicioModel
    @Environment(\.dismiss) private var dismiss
    @State private var isPickerPresented = false
    @State private var showEraseConfirmation = false
    @State private var showPrivacy = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Apps e sites") {
                    Button("Alterar seleção (\(model.selectedCount))") {
                        isPickerPresented = true
                    }
                }
                Section("Meta diária") {
                    Picker("Tempo", selection: $model.limitMinutes) {
                        ForEach([30, 60, 90, 120, 150, 180, 240], id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                }
                Section("Privacidade") {
                    Text("O Desvício não cria conta. As escolhas e o estado do bichinho ficam neste iPhone.")
                    Button("Política de privacidade") { showPrivacy = true }
                    Button("Apagar meus dados deste iPhone", role: .destructive) {
                        showEraseConfirmation = true
                    }
                }
                Section {
                    Button("Desativar controle", role: .destructive) {
                        model.stopControl()
                        dismiss()
                    }
                } footer: {
                    Text("Ao desativar, o Desvício para de monitorar e desbloqueia os apps.")
                }
            }
            .navigationTitle("Ajustes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluído") {
                        model.saveLimit()
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
            .onChange(of: model.selection) { _, _ in model.saveSelection() }
            .sheet(isPresented: $showPrivacy) { PrivacyView() }
            .confirmationDialog(
                "Apagar os dados do Desvício?",
                isPresented: $showEraseConfirmation,
                titleVisibility: .visible
            ) {
                Button("Apagar dados", role: .destructive) {
                    model.eraseLocalData()
                    dismiss()
                }
            } message: {
                Text("O monitoramento será desligado, os apps serão desbloqueados e o bichinho, a meta e a seleção serão apagados.")
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("O Desvício funciona sem conta e sem servidor próprio.")
                        .font(.title3.bold())
                    Group {
                        Text("Dados usados")
                            .font(.headline)
                        Text("Com sua autorização, as APIs de Tempo de Uso da Apple fornecem seleções protegidas de apps, categorias e sites e avisam quando a meta é atingida. O Desvício não lê mensagens, fotos nem o conteúdo da navegação.")
                        Text("Armazenamento")
                            .font(.headline)
                        Text("Nome e estado do bichinho, meta, seleção protegida e minutos de foco ficam no iPhone, em um contêiner compartilhado entre o app e sua extensão.")
                        Text("Coleta e compartilhamento")
                            .font(.headline)
                        Text("Esta versão não envia seus dados de uso para servidores, não usa anúncios ou serviços de análise e não compartilha esses dados com terceiros.")
                        Text("Apagar dados")
                            .font(.headline)
                        Text("Em Ajustes, toque em “Apagar meus dados deste iPhone”. O monitoramento será interrompido, os apps serão desbloqueados e os dados locais serão removidos.")
                    }
                    .foregroundStyle(Theme.ink.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Privacidade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

struct FocusView: View {
    @EnvironmentObject private var model: DesvicioModel
    @Environment(\.dismiss) private var dismiss
    @State private var duration = 25

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Spacer()
                Image(systemName: "leaf.fill")
                    .font(.system(size: 75))
                    .foregroundStyle(Theme.moss)
                Text("Um tempo só seu")
                    .font(.system(size: 29, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                if let session = model.focusSession {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let remaining = max(0, Int(session.endDate.timeIntervalSince(context.date)))
                        Text("\(remaining / 60):\(String(format: "%02d", remaining % 60))")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .onChange(of: remaining) { _, value in
                                if value == 0 { model.refresh() }
                            }
                    }
                    Button("Encerrar agora", role: .destructive) {
                        model.cancelFocus()
                    }
                    Text("Os apps escolhidos ficam bloqueados durante esta pausa.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Picker("Duração", selection: $duration) {
                        Text("15 min").tag(15)
                        Text("25 min").tag(25)
                        Text("45 min").tag(45)
                    }
                    .pickerStyle(.segmented)
                    Button("Começar") {
                        model.startFocus(minutes: duration)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Text("Ao começar, os apps que você escolheu serão bloqueados até o fim da pausa.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .padding(30)
            .frame(maxWidth: .infinity)
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Foco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .onAppear { model.refresh() }
    }
}

#if DEBUG
#Preview("Boas-vindas") {
    OnboardingView()
        .environmentObject(DesvicioModel())
}

#Preview("Tela do bichinho") {
    HomeView()
        .environmentObject(DesvicioModel())
}
#endif
