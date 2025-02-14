import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ngdart/src/dependencies/ngast/ngast.dart';

RecoveringExceptionHandler exceptionHandler = RecoveringExceptionHandler();

List<StandaloneTemplateAst> parse(String template) => const NgParser().parse(
      template,
      sourceUrl: '/test/parser_test.dart#inline',
      exceptionHandler: exceptionHandler,
      desugar: false,
    );

void main() {
  String input;
  exceptionHandler.exceptions.clear();
  var fileDir = p.join('test', 'ast_cli_tester_source.html');
  var file = File(fileDir.toString());
  input = file.readAsStringSync();
  //input = stdin.readLineSync(encoding: UTF8);
  var ast = parse(input);
  print('----------------------------------------------');
  if (exceptionHandler is ThrowingExceptionHandler) {
    print('CORRECT!');
    print(ast);
  }
  var exceptionsList = exceptionHandler.exceptions;
  if (exceptionsList.isEmpty) {
    print('CORRECT!');
    print(ast);
  } else {
    var visitor = const HumanizingTemplateAstVisitor();
    var fixed = ast.map((t) => t.accept(visitor)).join('');
    print('ORGNL: $input');
    print('FIXED: $fixed');

    print('\n\nERRORS:');
    for (var e in exceptionHandler.exceptions) {
      var context = input.substring(e.offset!, e.offset! + e.length!);
      print('${e.errorCode.message} :: $context at ${e.offset}');
    }
  }
}
