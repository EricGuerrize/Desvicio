import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const cream = Color(0xFFF8F5E9);
const ink = Color(0xFF26352D);
const moss = Color(0xFF416D52);
const mint = Color(0xFFA8DCC2);
const coral = Color(0xFFF4A393);

void main() => runApp(const DesvicioApp());

class AppState extends ChangeNotifier {
  static const channel = MethodChannel('com.desvicio.app/control');
  Map<String, dynamic> data = {};
  String? error;
  bool busy = false;
  bool loaded = false;

  bool get configured => data['configured'] == true;
  String get name => data['name'] as String? ?? 'Pingo';
  int get mood => data['mood'] as int? ?? 0;
  int get selectedCount => data['selectedCount'] as int? ?? 0;
  int get limitMinutes => data['limitMinutes'] as int? ?? 120;
  int get focusMinutes => data['focusMinutes'] as int? ?? 0;
  int? get focusEnd => data['focusEnd'] as int?;

  Future<void> refresh() async {
    try {
      data = await channel.invokeMapMethod<String, dynamic>('getState') ?? {};
      error = null;
    } on PlatformException catch (e) {
      error = e.message ?? 'Não foi possível acessar o Tempo de Uso.';
    } on MissingPluginException {
      error = 'O controle ainda não está disponível nesta plataforma.';
    } finally {
      loaded = true;
      notifyListeners();
    }
  }

  Future<void> action(String method, [Map<String, dynamic>? args]) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await channel.invokeMethod<void>(method, args);
      await refresh();
    } on PlatformException catch (e) {
      error = e.message ?? 'Não foi possível concluir a ação.';
    } on MissingPluginException {
      error = 'O controle ainda não está disponível nesta plataforma.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}

class DesvicioApp extends StatefulWidget {
  const DesvicioApp({super.key});
  @override
  State<DesvicioApp> createState() => _DesvicioAppState();
}

class _DesvicioAppState extends State<DesvicioApp> with WidgetsBindingObserver {
  final model = AppState();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    model.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) model.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Desvício',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: moss),
      textTheme: Theme.of(context).textTheme.apply(bodyColor: ink),
    ),
    home: ListenableBuilder(
      listenable: model,
      builder: (context, _) => !model.loaded
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : model.configured
          ? HomePage(model: model)
          : OnboardingPage(model: model),
    ),
  );
}

String moodName(int mood) => switch (mood) {
  1 => 'Cansadinho',
  2 => 'Dodói',
  3 => 'Fantasminha',
  _ => 'Animado',
};
String moodMessage(int mood) => switch (mood) {
  1 => 'Uma pausa cairia bem agora.',
  2 => 'Bora largar o scroll um pouquinho?',
  3 => 'Ainda dá tempo de cuidar de mim.',
  _ => 'Tá sobrando tempo pra viver lá fora.',
};

class Pet extends StatelessWidget {
  const Pet({super.key, required this.mood, this.size = 220});
  final int mood;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Bichinho ${moodName(mood).toLowerCase()}',
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PetPainter(mood)),
    ),
  );
}

class _PetPainter extends CustomPainter {
  _PetPainter(this.mood);
  final int mood;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final color = switch (mood) {
      1 => const Color(0xFFF7D987),
      2 => coral,
      3 => const Color(0xFFD4D0E9),
      _ => mint,
    };
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .5, s * .92),
        width: s * .7,
        height: s * .09,
      ),
      Paint()..color = ink.withValues(alpha: .12),
    );
    final body = Rect.fromCenter(
      center: Offset(s * .5, s * .53),
      width: s * .76,
      height: s * .78,
    );
    canvas.drawOval(body, Paint()..color = color);
    canvas.drawOval(
      body,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .014,
    );
    for (final x in [.42, .58]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * x, s * .46),
          width: s * .055,
          height: s * (mood == 1 ? .027 : .08),
        ),
        Paint()..color = ink,
      );
    }
    final mouth = Path();
    if (mood == 0) {
      mouth.moveTo(s * .43, s * .64);
      mouth.quadraticBezierTo(s * .5, s * .74, s * .57, s * .64);
    } else {
      mouth.moveTo(s * .45, s * .66);
      mouth.lineTo(s * .55, s * .66);
    }
    canvas.drawPath(
      mouth,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .014
        ..strokeCap = StrokeCap.round,
    );
    if (mood == 2) {
      canvas.drawCircle(
        Offset(s * .76, s * .31),
        s * .055,
        Paint()..color = cream,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PetPainter old) => old.mood != mood;
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => const Text(
    'desvício',
    style: TextStyle(color: moss, fontSize: 26, fontWeight: FontWeight.w900),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
    ),
    child: child,
  );
}

class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: moss,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(message, style: const TextStyle(color: Color(0xFFB13F36))),
  );
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.model});
  final AppState model;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final name = TextEditingController(text: widget.model.name);
  late int limit = widget.model.limitMinutes;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Brand(),
            const SizedBox(height: 24),
            const Text(
              'Menos scroll.\nMais vida.',
              style: TextStyle(
                fontSize: 42,
                height: 1.07,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Seu companheiro sente quando você se perde na tela — e comemora cada pausa.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Center(child: Pet(mood: 0, size: 190)),
            const SizedBox(height: 20),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dê um nome ao seu bichinho',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: name,
                    maxLength: 20,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Pingo',
                      filled: true,
                      fillColor: cream,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escolha o que te distrai',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Só os apps, categorias ou sites escolhidos contam para a meta.',
                  ),
                  TextButton.icon(
                    onPressed: model.busy || !Platform.isIOS
                        ? null
                        : () => model.action('chooseApps'),
                    icon: const Icon(Icons.apps),
                    label: Text(
                      model.selectedCount == 0
                          ? 'Escolher apps e sites'
                          : '${model.selectedCount} selecionado(s)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sua meta por dia',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: limit,
                    isExpanded: true,
                    items: [30, 60, 90, 120, 150, 180, 240]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text('$v minutos'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => limit = v ?? 120),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryAction(
              label: model.busy ? 'Preparando...' : 'Começar a cuidar',
              onPressed: model.busy || !Platform.isIOS
                  ? null
                  : () async {
                      await model.action('saveName', {'name': name.text});
                      if (model.error != null) return;
                      await model.action('saveLimit', {'minutes': limit});
                      if (model.error != null) return;
                      await model.action('configure');
                    },
            ),
            if (model.error != null) ErrorText(model.error!),
            const SizedBox(height: 14),
            Text(
              Platform.isIOS
                  ? 'O iPhone pedirá autorização para controlar os apps escolhidos. Seus dados ficam no aparelho.'
                  : 'O controle de apps no Android está em desenvolvimento. Por enquanto, o foco é o iPhone.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const PrivacyPage()),
              ),
              child: const Text('Política de privacidade'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.model});
  final AppState model;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              const Brand(),
              const Spacer(),
              IconButton(
                tooltip: 'Ajustes',
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsPage(model: model),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: mint.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Text(
                  'Esse é o ${model.name}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Pet(mood: model.mood, size: 230),
                Text(
                  moodName(model.mood),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(moodMessage(model.mood), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sua meta de hoje',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${model.limitMinutes} minutos nos apps escolhidos'),
                const SizedBox(height: 8),
                const Text(
                  'No limite, ele fica dodói. Após 30 minutos extras, os apps são bloqueados.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tempo de cuidado',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${model.focusMinutes} min de foco hoje'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryAction(
            label: 'Fazer uma pausa de foco',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => FocusPage(model: model)),
            ),
          ),
          if (model.error != null) ErrorText(model.error!),
        ],
      ),
    ),
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.model});
  final AppState model;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int limit = widget.model.limitMinutes;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.model.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apps e sites',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => model.action('chooseApps'),
                  child: Text('Alterar seleção (${model.selectedCount})'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meta diária',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: limit,
                  isExpanded: true,
                  items: [30, 60, 90, 120, 150, 180, 240]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text('$v minutos'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) async {
                    setState(() => limit = v ?? 120);
                    await model.action('saveLimit', {'minutes': limit});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacidade',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O Desvício não cria conta. Seus dados ficam neste aparelho.',
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyPage(),
                    ),
                  ),
                  child: const Text('Política de privacidade'),
                ),
                TextButton(
                  onPressed: () async {
                    final yes = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Apagar os dados do Desvício?'),
                        content: const Text(
                          'O monitoramento será desligado, os apps serão desbloqueados e os dados locais serão apagados.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Apagar dados'),
                          ),
                        ],
                      ),
                    );
                    if (yes == true) {
                      await model.action('eraseData');
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Apagar meus dados deste iPhone'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              await model.action('stopControl');
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Desativar controle'),
          ),
          if (model.error != null) ErrorText(model.error!),
        ],
      ),
    );
  }
}

class FocusPage extends StatefulWidget {
  const FocusPage({super.key, required this.model});
  final AppState model;
  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  int duration = 25;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    widget.model.refresh();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      final end = widget.model.focusEnd;
      if (end != null && end <= DateTime.now().millisecondsSinceEpoch) {
        widget.model.refresh();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final end = model.focusEnd;
    final remaining = end == null
        ? 0
        : ((end - DateTime.now().millisecondsSinceEpoch) / 1000).ceil().clamp(
            0,
            99999,
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa, size: 76, color: moss),
              const SizedBox(height: 18),
              const Text(
                'Um tempo só seu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              if (end != null) ...[
                Text(
                  '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => model.action('cancelFocus'),
                  child: const Text('Encerrar agora'),
                ),
                const Text(
                  'Os apps escolhidos ficam bloqueados durante a pausa.',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                SegmentedButton<int>(
                  segments: [15, 25, 45]
                      .map(
                        (v) => ButtonSegment(value: v, label: Text('$v min')),
                      )
                      .toList(),
                  selected: {duration},
                  onSelectionChanged: (values) =>
                      setState(() => duration = values.first),
                ),
                const SizedBox(height: 20),
                PrimaryAction(
                  label: 'Começar',
                  onPressed: model.busy
                      ? null
                      : () => model.action('startFocus', {'minutes': duration}),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Os apps escolhidos serão bloqueados até o fim da pausa.',
                  textAlign: TextAlign.center,
                ),
              ],
              if (model.error != null) ErrorText(model.error!),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacidade')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'O Desvício funciona sem conta e sem servidor próprio.',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dados usados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (Platform.isIOS)
          const Text(
            'Com sua autorização, o Tempo de Uso da Apple fornece seleções protegidas de apps, categorias e sites e avisa quando a meta é atingida. O Desvício não lê mensagens, fotos nem o conteúdo da navegação.',
          )
        else
          const Text(
            'O controle de tempo de tela no Android ainda não está disponível nesta versão.',
          ),
        const SizedBox(height: 16),
        const Text(
          'Armazenamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (Platform.isIOS)
          const Text(
            'Nome e estado do bichinho, meta, seleção protegida e minutos de foco ficam no iPhone, em um contêiner compartilhado entre o app e sua extensão.',
          )
        else
          const Text(
            'Na base Android atual, apenas o nome e a meta são guardados localmente no aparelho.',
          ),
        const SizedBox(height: 16),
        const Text(
          'Coleta e compartilhamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Esta versão não envia seus dados de uso para servidores, não usa anúncios ou serviços de análise e não compartilha esses dados com terceiros.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Apagar dados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (Platform.isIOS)
          const Text(
            'Em Ajustes, toque em “Apagar meus dados deste iPhone”. O monitoramento será interrompido, os apps serão desbloqueados e os dados locais serão removidos.',
          )
        else
          const Text(
            'No Android, os dados locais desta versão podem ser removidos nos ajustes do sistema ao limpar os dados do app.',
          ),
      ],
    ),
  );
}
