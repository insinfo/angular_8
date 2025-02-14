import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:ngdart/src/dependencies/ngcompiler/v2/context.dart';

import 'resolve.dart';

Future<T> _recordLogs<T>(
  Future<T> Function() run,
  void Function(List<LogRecord>) onLog,
) {
  final logger = Logger('_recordLogs');
  final records = <LogRecord>[];
  final subscription = logger.onRecord.listen(records.add);
  return scopeLogAsync(() async {
    return runWithContext(
      CompileContext.forTesting(),
      run,
    ).then((result) {
      subscription.cancel();
      onLog(records);
      return result;
    });
  }, logger);
}

/// Executes the [run] function with the result of analyzing [source].
///
/// Similar to [runsExpecting] as it verifies the expected warnings or errors.
Future<void> compilesExpecting(
  String source,
  Future<void> Function(LibraryElement) run, {
  Object? /* Matcher | List<Matcher> | List<String> */ errors,
  Object? /* Matcher | List<Matcher> | List<String> */ warnings,
}) {
  return resolveLibrary(source).then((lib) {
    return runsExpecting(
      () => run(lib),
      errors: errors,
      warnings: warnings,
    );
  });
}

/// Executes the [run] function, and expects specified [errors] or [warnings].
Future<T> runsExpecting<T>(
  Future<T> Function() run, {
  Object? /* Matcher | List<Matcher> | List<String> */ errors,
  Object? /* Matcher | List<Matcher> | List<String> */ warnings,
}) {
  errors ??= anything;
  warnings ??= anything;
  return _recordLogs(run, (records) {
    expect(
      records.where((r) => r.level == Level.SEVERE).map((r) => r.message),
      errors,
    );
    expect(
      records.where((r) => r.level == Level.WARNING).map((r) => r.message),
      warnings,
    );
  });
}
