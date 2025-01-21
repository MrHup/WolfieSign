import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  level: kDebugMode ? Level.debug : Level.info,
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 8,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

Logger getLogger() {
  return logger;
}
