import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';

import 'package:nganalyzer/src/version.dart';

class AngularAnalyzerPlugin extends ServerPlugin {
  AngularAnalyzerPlugin({required super.resourceProvider});

  @override
  List<String> get fileGlobsToAnalyze => [
        '**/*.dart',
        '**/*.html',
        // Stretch goals:
        // '**/*.css',
        // '**/*.scss',
        // '**/*.sass',
      ];

  @override
  String get name => 'Angular Analyzer Plugin';

  @override
  String get version => packageVersion;

  @override
  Future<void> analyzeFile(
      {required AnalysisContext analysisContext, required String path}) {
    // TODO: implement analyzeFile
    throw UnimplementedError();
  }
}
