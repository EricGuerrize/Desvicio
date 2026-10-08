import SwiftUI
import FamilyControls

struct RootView: View {
    @EnvironmentObject private var model: DesvicioModel

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
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var model: DesvicioModel
    @State private var name = "Pingo"
    @State private var isPickerPresented = false

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
                    Text("Seu companheiro sente quando você se perde na tela — e comemora cada pausa.")
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.ink.opacity(0.7))
                }

                PetView(mood: .happy, size: 190)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)

                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Dê um nome ao seu bichinho", systemImage: "heart.fill")
                            .font(.headline)
                        TextField("Nome", text: $name)
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
                    model.saveName(name)
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
            }
            .padding(24)
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
        .onChange(of: model.selection) { _, _ in model.saveSelection() }
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
        }
    }
}

struct FocusView: View {
    @EnvironmentObject private var model: DesvicioModel
    @Environment(\.dismiss) private var dismiss
    @State private var endDate: Date?
    @State private var duration = 25
    @State private var completed = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Spacer()
                Image(systemName: "leaf.fill")
                    .font(.system(size: 75))
                    .foregroundStyle(Theme.moss)
                Text(completed ? "Boa! Seu bichinho agradece." : "Um tempo só seu")
                    .font(.system(size: 29, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                if let endDate {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let remaining = max(0, Int(endDate.timeIntervalSince(context.date)))
                        Text("\(remaining / 60):\(String(format: "%02d", remaining % 60))")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .onChange(of: remaining) { _, value in
                                if value == 0 && !completed {
                                    completed = true
                                    model.finishFocus(minutes: duration)
                                    self.endDate = nil
                                }
                            }
                    }
                } else if !completed {
                    Picker("Duração", selection: $duration) {
                        Text("10 min").tag(10)
                        Text("25 min").tag(25)
                        Text("45 min").tag(45)
                    }
                    .pickerStyle(.segmented)
                    Button("Começar") {
                        endDate = .now.addingTimeInterval(TimeInterval(duration * 60))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                Text("Deixe o celular de lado. Volte aqui quando o tempo terminar.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
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
    }
}
