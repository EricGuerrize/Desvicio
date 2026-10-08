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
              'name': 'Pingo',
              'mood': 0,
              'selectedCount': 0,
              'limitMinutes': 120,
              'focusMinutes': 0,
            };
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(const DesvicioApp());
    await tester.pumpAndSettle();

    expect(find.text('Menos scroll.\nMais vida.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Pingo',
    );
  });
}
