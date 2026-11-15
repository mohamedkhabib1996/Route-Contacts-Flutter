import 'dart:io';
import 'dart:ui' as ui;

import 'package:contact_app/data/contact_store.dart';
import 'package:contact_app/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _flutterSdk = String.fromEnvironment('FLUTTER_SDK');
const _outputDirectory = String.fromEnvironment(
  'DEMO_OUTPUT_DIR',
  defaultValue: 'build/demo_frames',
);
const _framesPerSecond = 10;

Future<void> _loadFonts() async {
  if (_flutterSdk.isEmpty) {
    throw StateError('Pass --dart-define=FLUTTER_SDK=/path/to/flutter.');
  }
  final fonts = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = await File(
      '$_flutterSdk/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
    ).readAsBytes();
    fonts.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await fonts.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}

class _SessionRecorder {
  _SessionRecorder(this.tester, this.boundaryKey);

  final WidgetTester tester;
  final GlobalKey boundaryKey;
  var frameCount = 0;

  Future<void> record(int frames) async {
    for (var index = 0; index < frames; index++) {
      await tester.pump(const Duration(milliseconds: 1000 ~/ _framesPerSecond));
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final frame = frameCount.toString().padLeft(5, '0');
        await File('$_outputDirectory/frame_$frame.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      frameCount++;
    }
  }

  Future<void> type(Finder field, String value) async {
    await tester.tap(field);
    for (var length = 1; length <= value.length; length++) {
      await tester.enterText(field, value.substring(0, length));
      await record(2);
    }
  }
}

void main() {
  testWidgets('record an automated Flutter contact session', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);

    // The production storage adapter uses the plugin's test backend here.
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      final directory = Directory(_outputDirectory);
      if (directory.existsSync() && directory.listSync().isNotEmpty) {
        throw StateError('Use an empty DEMO_OUTPUT_DIR for a fresh recording.');
      }
      await directory.create(recursive: true);
      await _loadFonts();
    });
    final store = PreferencesContactStore();
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ContactsApp(store: store),
      ),
    );
    await tester.pump();
    final recorder = _SessionRecorder(tester, boundaryKey);
    await recorder.record(40);
    expect(find.text('No contacts yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Add contact'));
    await recorder.record(30);
    final fields = find.byType(TextFormField);
    await recorder.type(fields.at(0), 'Demo Contact');
    await recorder.record(6);
    await recorder.type(fields.at(1), 'demo@example.com');
    await recorder.record(6);
    await recorder.type(fields.at(2), '+12025550123');
    await recorder.record(28);

    await tester.ensureVisible(find.text('Save contact'));
    await tester.tap(find.text('Save contact'));
    await recorder.record(60);
    expect((await store.load()).single.name, 'Demo Contact');
    expect(find.text('Demo Contact'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await recorder.record(18);
    expect(await store.load(), isEmpty);
    expect(find.text('No contacts yet'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await recorder.record(80);
    expect((await store.load()).single.email, 'demo@example.com');
    expect(find.text('Demo Contact'), findsOneWidget);
    expect(tester.takeException(), isNull);

    stdout.writeln(
      'Recorded ${recorder.frameCount} actual Flutter frames at '
      '$_framesPerSecond fps (${recorder.frameCount / _framesPerSecond}s).',
    );
  });
}
