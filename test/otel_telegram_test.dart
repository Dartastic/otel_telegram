// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_telegram/otel_telegram.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_telegram-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('sendMessage records CLIENT span', () async {
    await tracedTelegram<String>(
      method: 'sendMessage',
      botUsername: 'mybot',
      chatId: '12345',
      messageId: 9,
      invoke: () async => 'ok',
    );
    final a = attrsOf(spans.findSpanByName('telegram sendMessage')!);
    expect(a['telegram.method'], 'sendMessage');
    expect(a['telegram.bot.username'], 'mybot');
    expect(a['telegram.chat.id'], '12345');
    expect(a['telegram.message.id'], 9);
  });

  test('suppression skips spans', () async {
    await runWithoutTelegramInstrumentationAsync(() async {
      await tracedTelegram<String>(
        method: 'sendMessage',
        invoke: () async => 'ok',
      );
    });
    expect(spans.findSpansStartingWith('telegram '), isEmpty);
  });
}
