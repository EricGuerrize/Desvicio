import 'package:desvicio/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mostra o início com dados locais existentes', (tester) async {
    const channel = MethodChannel('com.desvicio.app/control');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getState') {
            return <String, Object>{
              'configured': false,
              'name': 'Meu Cérebro',
              'mood': 0,
              'selectedCount': 0,
              'limitMinutes': 120,
              'focusMinutes': 0,
              'streakDays': 0,
            };
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const DesvicioApp());
    await tester.pumpAndSettle();

    // Etapa 1: Diagnóstico de tempo de tela
    expect(
      find.text('Quanto tempo você passa no celular por dia?'),
      findsOneWidget,
    );

    // Avança para Etapa 2: Comparativo Brainrot
    final nextBtn = find.text('Continuar');
    await tester.scrollUntilVisible(nextBtn, 100);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    expect(
      find.text('O que o scroll infinito faz com a sua mente'),
      findsOneWidget,
    );

    // Avança para Etapa 3: Seleção de apps e redes
    await tester.scrollUntilVisible(nextBtn, 100);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    expect(
      find.text('Quais apps mais sugam a sua atenção?'),
      findsOneWidget,
    );
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);

    // Avança para Etapa 4: Conheça o cérebro
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Conheça o seu cérebro'), findsOneWidget);

    // Verifica que o TextField começa VAZIO e o placeholder é 'Meu Cérebro'
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller!.text, '');
    expect(textField.decoration!.hintText, 'Meu Cérebro');

    // Clica em 'Começar a cuidar' e verifica que salva 'Meu Cérebro' como padrão
    String? capturedName;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getState') {
            return <String, Object>{
              'configured': true,
              'name': capturedName ?? 'Meu Cérebro',
              'mood': 0,
              'selectedCount': 0,
              'limitMinutes': 120,
              'focusMinutes': 0,
              'streakDays': 0,
            };
          }
          if (call.method == 'saveName') {
            final args = call.arguments as Map<dynamic, dynamic>?;
            capturedName = args?['name'] as String?;
            return null;
          }
          return null;
        });

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar a cuidar'));
    await tester.pumpAndSettle();

    expect(capturedName, 'Meu Cérebro');
  });
}
