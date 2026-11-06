// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_telegram_suppression.dart';

const _tracerName = 'dartastic_otel_libs_telegram';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

/// Wraps a Telegram Bot API method call in a CLIENT span. [method]
/// is the Bot API verb (e.g. `sendMessage`, `editMessageText`,
/// `setWebhook`).
Future<T> tracedTelegram<T>({
  required String method,
  required Future<T> Function() invoke,
  String? botUsername,
  String? chatId,
  int? messageId,
}) async {
  if (telegramInstrumentationSuppressed()) {
    return invoke();
  }
  final m = <String, Object>{
    'telegram.method': method,
  };
  if (botUsername != null) m['telegram.bot.username'] = botUsername;
  if (chatId != null) m['telegram.chat.id'] = chatId;
  if (messageId != null) m['telegram.message.id'] = messageId;

  final span = _tracer().startSpan(
    'telegram $method',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    return await invoke();
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
