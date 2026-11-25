import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;

import 'package:keep_links/utils/utils.dart';

late Logger _logger;
const String logTag = "keep_links_tag";
bool isLoggingInitiated = false;

enum LogLevel { info, debug, error }

extension LogLevelValue on LogLevel {
  /// Source of the values - [https://github.com/dart-lang/core/blob/main/pkgs/logging/lib/src/level.dart)
  int get value {
    switch (this) {
      case LogLevel.debug:
        return 400;
      case LogLevel.info:
        return 800;
      case LogLevel.error:
        return 1200;
    }
  }
}

void initLogger() {
  if (isLoggingInitiated) {
    return;
  }
  isLoggingInitiated = true;
  var output = ConsoleOutput();
  _logger = Logger(
    printer: SimplePrinter(),
    filter: ProductionFilter(),
    level: kDebugMode ? Level.debug : Level.warning,
    output: output,
  );
}

void logError(
  String message,
  Object? error, {
  StackTrace? stackTrace,
  bool isShowToastInDebug = false,
}) {
  printDebug(
    message,
    level: LogLevel.error,
    stackTrace: stackTrace,
    error: error,
    showToast: isShowToastInDebug && kDebugMode,
  );
}

void logDebug(String message) {
  printDebug(message, level: LogLevel.debug);
}

void logInfo(String message, {bool showToast = false}) {
  printDebug(message, level: LogLevel.info, showToast: showToast);
}

void printDebug(
  String message, {
  String tag = logTag,
  LogLevel level = LogLevel.debug,
  StackTrace? stackTrace,
  Object? error,
  bool showToast = false,
}) {
  if (kReleaseMode) return;
  if (showToast) Utils.showToast(message, toastLength: Toast.LENGTH_LONG);

  switch (level) {
    case LogLevel.info:
      developer.log(message, level: level.value, name: tag);
      _logger.i(message);
      break;
    case LogLevel.debug:
      developer.log(message, name: tag, level: level.value);
      _logger.d(message);
      break;
    case LogLevel.error:
      StackTrace fallbackStackTrace = StackTrace.current;
      if (error != null && error is Error) {
        fallbackStackTrace = error.stackTrace ?? fallbackStackTrace;
      }
      developer.log(
        message,
        name: tag,
        level: level.value,
        stackTrace: stackTrace ?? fallbackStackTrace,
        error: error,
      );
      _logger.e(
        message,
        error: error,
        stackTrace: stackTrace ?? fallbackStackTrace,
      );
      break;
  }
}
