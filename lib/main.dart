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

  final Set<String> selectedDistractions = {
    'Instagram',
    'TikTok',
    'YouTube',
    'X (Twitter)',
  };

  void toggleDistraction(String item) {
    if (selectedDistractions.contains(item)) {
      selectedDistractions.remove(item);
    } else {
      selectedDistractions.add(item);
    }
    notifyListeners();
  }

  void addCustomDistraction(String item) {
    final clean = item.trim();
    if (clean.isNotEmpty) {
      selectedDistractions.add(clean);
      notifyListeners();
    }
  }

  int get effectiveSelectedCount =>
      selectedCount > 0 ? selectedCount : selectedDistractions.length;

  bool get configured => data['configured'] == true;
  String get name => data['name'] as String? ?? 'Meu Cérebro';
  int get mood => data['mood'] as int? ?? 0;
  int get selectedCount => data['selectedCount'] as int? ?? 0;
  int get limitMinutes => data['limitMinutes'] as int? ?? 120;
  int get focusMinutes => data['focusMinutes'] as int? ?? 0;
  int get streakDays => data['streakDays'] as int? ?? 0;
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
  1 => 'Cansado',
  2 => 'Fritando',
  3 => 'Pifou',
  _ => 'Saudável',
};
String moodMessage(int mood) => switch (mood) {
  1 => 'O excesso de tela começou a pesar na mente.',
  2 => 'Seu cérebro tá fritando no scroll infinito!',
  3 => 'Seu cérebro pifou pra se proteger. Desconecte agora.',
  _ => 'Seu cérebro tá fresco e pronto pra viver.',
};

class BrainAvatar extends StatelessWidget {
  const BrainAvatar({super.key, required this.mood, this.size = 220});
  final int mood;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cérebro ${moodName(mood).toLowerCase()}',
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrainPainter(mood)),
    ),
  );
}

typedef Pet = BrainAvatar;

class _BrainPainter extends CustomPainter {
  _BrainPainter(this.mood);
  final int mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    // Sombra no chão
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .5, s * .93),
        width: s * .72,
        height: s * .09,
      ),
      Paint()..color = ink.withValues(alpha: .12),
    );

    // Cores de acordo com o estado do cérebro
    final brainColor = switch (mood) {
      1 => const Color(0xFFFED7AA), // Cansado: âmbar/pêssego
      2 => const Color(0xFFFF7A66), // Fritando: coral/vermelho vivo
      3 => const Color(0xFFD4D0E9), // Pifou: lavanda/cinza apagado
      _ => const Color(0xFFFFB5C5), // Saudável: rosa fresco clássico de cérebro
    };

    final outlinePaint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .016
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Silhueta dos dois hemisférios do cérebro
    final brainPath = Path();
    brainPath.moveTo(s * .50, s * .28);
    // Lobo superior esquerdo
    brainPath.cubicTo(s * .38, s * .20, s * .22, s * .22, s * .16, s * .34);
    // Lobo temporal esquerdo
    brainPath.cubicTo(s * .11, s * .42, s * .12, s * .54, s * .18, s * .62);
    // Lobo inferior esquerdo
    brainPath.cubicTo(s * .14, s * .72, s * .25, s * .84, s * .38, s * .84);
    // Base esquerda até a fenda central
    brainPath.cubicTo(s * .44, s * .84, s * .48, s * .80, s * .50, s * .80);
    // Base direita
    brainPath.cubicTo(s * .52, s * .80, s * .56, s * .84, s * .62, s * .84);
    // Lobo inferior direito
    brainPath.cubicTo(s * .75, s * .84, s * .86, s * .72, s * .82, s * .62);
    // Lobo temporal direito
    brainPath.cubicTo(s * .88, s * .54, s * .89, s * .42, s * .84, s * .34);
    // Lobo superior direito
    brainPath.cubicTo(s * .78, s * .22, s * .62, s * .20, s * .50, s * .28);
    brainPath.close();

    canvas.drawPath(brainPath, Paint()..color = brainColor);
    canvas.drawPath(brainPath, outlinePaint);

    // Fenda divisória central
    final fissureTop = Path()
      ..moveTo(s * .50, s * .28)
      ..cubicTo(s * .49, s * .34, s * .51, s * .40, s * .50, s * .44);
    canvas.drawPath(fissureTop, outlinePaint);

    final fissureBottom = Path()
      ..moveTo(s * .50, s * .72)
      ..cubicTo(s * .49, s * .76, s * .51, s * .78, s * .50, s * .80);
    canvas.drawPath(fissureBottom, outlinePaint);

    // Dobras/Sulcos no hemisfério esquerdo
    final leftGyri = Path()
      ..moveTo(s * .20, s * .38)
      ..quadraticBezierTo(s * .30, s * .34, s * .36, s * .40)
      ..moveTo(s * .16, s * .52)
      ..cubicTo(s * .24, s * .48, s * .30, s * .56, s * .34, s * .52)
      ..moveTo(s * .22, s * .68)
      ..quadraticBezierTo(s * .30, s * .74, s * .38, s * .70);
    canvas.drawPath(leftGyri, outlinePaint);

    // Dobras/Sulcos no hemisfério direito
    final rightGyri = Path()
      ..moveTo(s * .80, s * .38)
      ..quadraticBezierTo(s * .70, s * .34, s * .64, s * .40)
      ..moveTo(s * .84, s * .52)
      ..cubicTo(s * .76, s * .48, s * .70, s * .56, s * .66, s * .52)
      ..moveTo(s * .78, s * .68)
      ..quadraticBezierTo(s * .70, s * .74, s * .62, s * .70);
    canvas.drawPath(rightGyri, outlinePaint);

    // Expressões faciais e reações do cérebro
    if (mood == 0) {
      // SAUDÁVEL: bochechas rosadas, olhos brilhantes e sorriso
      final cheekPaint = Paint()..color = const Color(0xFFFF85A1).withValues(alpha: .55);
      canvas.drawCircle(Offset(s * .38, s * .63), s * .04, cheekPaint);
      canvas.drawCircle(Offset(s * .62, s * .63), s * .04, cheekPaint);

      for (final x in [.43, .57]) {
        canvas.drawCircle(Offset(s * x, s * .57), s * .035, Paint()..color = ink);
        canvas.drawCircle(Offset(s * (x - .01), s * .56), s * .012, Paint()..color = Colors.white);
      }

      final mouth = Path()
        ..moveTo(s * .46, s * .64)
        ..quadraticBezierTo(s * .50, s * .71, s * .54, s * .64);
      canvas.drawPath(mouth, outlinePaint);

      final sparkle = Path()
        ..moveTo(s * .50, s * .12)
        ..lineTo(s * .50, s * .20)
        ..moveTo(s * .46, s * .16)
        ..lineTo(s * .54, s * .16);
      canvas.drawPath(sparkle, Paint()..color = moss..style = PaintingStyle.stroke..strokeWidth = s * .015..strokeCap = StrokeCap.round);
    } else if (mood == 1) {
      // CANSADO: olhos caídos e gota de suor
      for (final x in [.43, .57]) {
        final eye = Path()
          ..moveTo(s * (x - .03), s * .58)
          ..quadraticBezierTo(s * x, s * .55, s * (x + .03), s * .58);
        canvas.drawPath(eye, outlinePaint);
      }
      final mouth = Path()
        ..moveTo(s * .47, s * .66)
        ..lineTo(s * .53, s * .66);
      canvas.drawPath(mouth, outlinePaint);

      final sweat = Path()
        ..moveTo(s * .82, s * .38)
        ..quadraticBezierTo(s * .85, s * .43, s * .82, s * .45)
        ..arcToPoint(Offset(s * .80, s * .44), radius: Radius.circular(s * .015))
        ..close();
      canvas.drawPath(sweat, Paint()..color = const Color(0xFF60A5FA));
      canvas.drawPath(sweat, outlinePaint..strokeWidth = s * .01);
    } else if (mood == 2) {
      // FRITANDO: olhos espirais e fumaça de calor no topo
      for (final x in [.42, .58]) {
        canvas.drawCircle(Offset(s * x, s * .57), s * .04, outlinePaint);
        canvas.drawCircle(Offset(s * x, s * .57), s * .015, Paint()..color = ink);
      }
      final mouth = Path()
        ..moveTo(s * .44, s * .67)
        ..quadraticBezierTo(s * .47, s * .64, s * .50, s * .67)
        ..quadraticBezierTo(s * .53, s * .70, s * .56, s * .67);
      canvas.drawPath(mouth, outlinePaint);

      final steam = Path()
        ..moveTo(s * .36, s * .18)
        ..quadraticBezierTo(s * .34, s * .12, s * .38, s * .08)
        ..moveTo(s * .64, s * .18)
        ..quadraticBezierTo(s * .66, s * .12, s * .62, s * .08);
      canvas.drawPath(steam, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = s * .016..strokeCap = StrokeCap.round);
    } else {
      // PIFOU: olhos em cruz, boca em 'o' e Zzz
      for (final x in [.43, .57]) {
        final cross = Path()
          ..moveTo(s * (x - .025), s * .54)
          ..lineTo(s * (x + .025), s * .60)
          ..moveTo(s * (x + .025), s * .54)
          ..lineTo(s * (x - .025), s * .60);
        canvas.drawPath(cross, outlinePaint);
      }
      canvas.drawCircle(Offset(s * .50, s * .68), s * .025, outlinePaint);

      final z1 = Path()
        ..moveTo(s * .74, s * .16)..lineTo(s * .80, s * .16)
        ..lineTo(s * .74, s * .22)..lineTo(s * .80, s * .22);
      final z2 = Path()
        ..moveTo(s * .82, s * .10)..lineTo(s * .87, s * .10)
        ..lineTo(s * .82, s * .15)..lineTo(s * .87, s * .15);
      canvas.drawPath(z1, outlinePaint..strokeWidth = s * .014);
      canvas.drawPath(z2, outlinePaint..strokeWidth = s * .012);
    }
  }

  @override
  bool shouldRepaint(covariant _BrainPainter old) => old.mood != mood;
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

class DistractionItem {
  const DistractionItem({
    required this.name,
    required this.icon,
    required this.subtitle,
  });
  final String name;
  final String icon;
  final String subtitle;
}

const defaultDistractions = <DistractionItem>[
  DistractionItem(name: 'Instagram', icon: '📸', subtitle: 'Reels e feeds'),
  DistractionItem(name: 'TikTok', icon: '🎵', subtitle: 'Vídeos curtos e rolagem'),
  DistractionItem(name: 'YouTube', icon: '▶️', subtitle: 'Shorts e vídeos longos'),
  DistractionItem(name: 'X (Twitter)', icon: '🐦', subtitle: 'Feed infinito e discussões'),
  DistractionItem(name: 'Kwai', icon: '📹', subtitle: 'Vídeos rápidos e trends'),
  DistractionItem(name: 'Reddit', icon: '👾', subtitle: 'Fóruns, memes e threads'),
  DistractionItem(name: 'Facebook', icon: '📘', subtitle: 'Feed, grupos e vídeos'),
  DistractionItem(name: 'WhatsApp', icon: '💬', subtitle: 'Conversas e status'),
  DistractionItem(name: 'Jogos Mobile', icon: '🎮', subtitle: 'Jogos casuais e partidas'),
  DistractionItem(name: 'Netflix & Streaming', icon: '🎬', subtitle: 'Séries e filmes'),
  DistractionItem(name: 'Sites & Notícias', icon: '🌐', subtitle: 'Portais de fofoca e notícias'),
  DistractionItem(name: 'Apostas & Bets', icon: '🎰', subtitle: 'Cassinos online e bets'),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.model});
  final AppState model;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;
  int _hoursBucket = 1;
  late final name = TextEditingController();
  late int limit = widget.model.limitMinutes;
  final siteController = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    siteController.dispose();
    super.dispose();
  }

  String _impactDuration(int bucket) => switch (bucket) {
    0 => 'Até 30 dias inteiros do ano',
    1 => 'Cerca de 60 dias inteiros do ano',
    2 => 'Quase 92 dias inteiros do ano',
    _ => 'Mais de 120 dias inteiros do ano',
  };

  String _impactDescription(int bucket) => switch (bucket) {
    0 => 'Você já tem um uso moderado, mas pequenos hábitos ainda podem salvar horas da sua semana.',
    1 => 'São 2 meses inteiros acordado só olhando para a tela. Tempo suficiente para ler mais de 15 livros.',
    2 => 'São 3 meses do seu ano inteiramente consumidos pelo algoritmo. Seu cérebro passa horas no piloto automático.',
    _ => 'Mais de um terço de todo o seu tempo acordado está indo para o feed. Seu cérebro está pedindo socorro!',
  };

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_step > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _step--),
                    tooltip: 'Voltar',
                  )
                else
                  const Brand(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: mint.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Etapa ${_step + 1} de 4',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: moss),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_step == 0) ...[
              const Text(
                'Quanto tempo você passa no celular por dia?',
                style: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'A maioria das pessoas subestima o tempo que perde rolando feeds sem rumo.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 22),
              ...[
                (0, '⚡ 1 a 2 horas', 'Uso leve e consciente'),
                (1, '📱 3 a 4 horas', 'Média de quem usa redes sociais'),
                (2, '🔥 5 a 7 horas', 'Uso intenso e automático'),
                (3, '💀 8+ horas', 'Modo zumbi / hiperconectado'),
              ].map((opt) {
                final isSelected = _hoursBucket == opt.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _hoursBucket = opt.$1),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? mint.withValues(alpha: .35) : Colors.white,
                        border: Border.all(color: isSelected ? moss : Colors.black12, width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.$2,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(opt.$3, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? moss : Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _impactDuration(_hoursBucket),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _impactDescription(_hoursBucket),
                      style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryAction(
                label: 'Continuar',
                onPressed: () => setState(() => _step = 1),
              ),
            ] else if (_step == 1) ...[
              const Text(
                'O que o scroll infinito faz com a sua mente',
                style: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'O excesso de vídeos curtos e notificações drena sua dopamina e capacidade de foco.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: moss.withValues(alpha: .3)),
                      ),
                      child: Column(
                        children: [
                          const BrainAvatar(mood: 0, size: 100),
                          const SizedBox(height: 8),
                          const Text(
                            'Saudável',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: moss),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '✓ Foco nítido\n✓ Sono profundo\n✓ Mais calma\n✓ Disposição',
                            style: TextStyle(fontSize: 12, height: 1.5, color: ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: coral.withValues(alpha: .5)),
                      ),
                      child: Column(
                        children: [
                          const BrainAvatar(mood: 2, size: 100),
                          const SizedBox(height: 8),
                          const Text(
                            'Fritando',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFD9483B)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '✗ Névoa mental\n✗ Ansiedade\n✗ Foco quebrado\n✗ Fadiga mental',
                            style: TextStyle(fontSize: 12, height: 1.5, color: ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Panel(
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'O Desvício ajuda você a impor pausas gentis e salvar a sua mente antes que ela chegue no modo exaustão.',
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryAction(
                label: 'Continuar',
                onPressed: () => setState(() => _step = 2),
              ),
            ] else if (_step == 2) ...[
              const Text(
                'Quais apps mais sugam a sua atenção?',
                style: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Marque as redes sociais, aplicativos e sites que mais te prendem na tela.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: mint.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: moss, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${model.selectedDistractions.length} item(ns) selecionado(s)',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: moss),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...defaultDistractions.map((item) {
                final isSelected = model.selectedDistractions.contains(item.name);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => model.toggleDistraction(item.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : cream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? moss : Colors.black12,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(item.icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            activeColor: moss,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            onChanged: (_) => model.toggleDistraction(item.name),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adicionar outro site ou domínio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: siteController,
                            decoration: InputDecoration(
                              hintText: 'ex: globo.com ou twitter.com',
                              filled: true,
                              fillColor: cream,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            if (siteController.text.trim().isNotEmpty) {
                              model.addCustomDistraction(siteController.text.trim());
                              siteController.clear();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: moss,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Adicionar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (Platform.isIOS)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apps, color: moss),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          model.selectedCount == 0
                              ? 'Conectar ao Tempo de Uso do iOS (opcional)'
                              : '${model.selectedCount} selecionado(s) pelo iOS',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: model.busy ? null : () => model.action('chooseApps'),
                        child: const Text('Ajustar'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              PrimaryAction(
                label: 'Continuar',
                onPressed: () => setState(() => _step = 3),
              ),
            ] else ...[
              const Text(
                'Conheça o seu cérebro',
                style: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dê um nome a ele e escolha o limite diário antes dele começar a fritar.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Center(child: BrainAvatar(mood: 0, size: 180)),
              const SizedBox(height: 18),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dê um nome ao seu cérebro',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: name,
                      maxLength: 20,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Meu Cérebro',
                        filled: true,
                        fillColor: cream,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Se deixar vazio, usaremos "Meu Cérebro".',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
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
                    const SizedBox(height: 4),
                    const Text(
                      'Tempo de tela permitido antes de fritar:',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: limit,
                      isExpanded: true,
                      items: [30, 60, 90, 120, 150, 180, 240]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(
                                v < 60 ? '$v minutos' : '${v ~/ 60}h ${v % 60 == 0 ? "" : "${v % 60}min"} ($v min)',
                              ),
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
                onPressed: model.busy
                    ? null
                    : () async {
                        final enteredName = name.text.trim();
                        final brainName = enteredName.isEmpty ? 'Meu Cérebro' : enteredName;
                        await model.action('saveName', {'name': brainName});
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
                    ? 'Seus dados de tela ficam 100% no seu iPhone. O Desvício não possui servidores nem anúncios.'
                    : 'Os dados do seu cérebro ficam guardados com segurança no seu aparelho.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const PrivacyPage()),
                ),
                child: const Text('Política de privacidade'),
              ),
            ],
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
                  model.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (model.streakDays > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            '${model.streakDays} ${model.streakDays == 1 ? "dia" : "dias"} sem fritar',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                BrainAvatar(mood: model.mood, size: 230),
                const SizedBox(height: 8),
                Text(
                  moodName(model.mood),
                  style: const TextStyle(
                    fontSize: 22,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Apps monitorados',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${model.selectedDistractions.length} selecionado(s)',
                      style: const TextStyle(color: moss, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: model.selectedDistractions.map((item) {
                    final dist = defaultDistractions.firstWhere(
                      (d) => d.name == item,
                      orElse: () => DistractionItem(name: item, icon: '🌐', subtitle: ''),
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dist.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(dist.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (model.selectedCount > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${model.selectedCount} app(s)/site(s) vinculados ao Tempo de Uso do iOS',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
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
                  'Na metade ele cansa, no limite ele frita. Após 30 minutos extras, os apps são bloqueados pra salvar sua cabeça.',
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
                  'Tempo de respiro',
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
                  'Apps e sites monitorados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: defaultDistractions.map((item) {
                    final isSelected = model.selectedDistractions.contains(item.name);
                    return FilterChip(
                      selected: isSelected,
                      label: Text('${item.icon} ${item.name}'),
                      selectedColor: mint.withValues(alpha: .5),
                      checkmarkColor: moss,
                      onSelected: (_) => model.toggleDistraction(item.name),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                if (Platform.isIOS)
                  TextButton.icon(
                    onPressed: () => model.action('chooseApps'),
                    icon: const Icon(Icons.apple),
                    label: Text(
                      model.selectedCount == 0
                          ? 'Vincular no Tempo de Uso do iPhone'
                          : 'Alterar seleção do iPhone (${model.selectedCount})',
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
                          'O monitoramento será desligado, os apps serão desbloqueados e os dados locais do seu cérebro serão apagados.',
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
            'Nome e estado do cérebro, meta, seleção protegida e minutos de foco ficam no iPhone, em um contêiner compartilhado entre o app e sua extensão.',
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
