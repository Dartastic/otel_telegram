// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_telegram/otel_telegram.dart';

/// Traces Telegram Bot calls with OpenTelemetry.
///
/// `otel_telegram` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Telegram Bot call in
/// [tracedTelegram]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'telegram-example');

  // Wraps a Telegram Bot API method call in a CLIENT span.
  final telegramId = await tracedTelegram<String>(
    method: 'POST',
    botUsername: 'example',
    chatId: 'chat_8f3a2c',
    messageId: 1,
    invoke: () async {
      // Make the Telegram Bot call here, then report what it returned.
      return 'telegram_8f3a2c';
    },
  );
  OTelLog.info('tracedTelegram returned $telegramId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutTelegramInstrumentationAsync.
  await runWithoutTelegramInstrumentationAsync(
    () => tracedTelegram<String>(
      method: 'POST',
      botUsername: 'example',
      chatId: 'chat_8f3a2c',
      messageId: 1,
      invoke: () async {
        return 'telegram_8f3a2c';
      },
    ),
  );

  await OTel.shutdown();
}
