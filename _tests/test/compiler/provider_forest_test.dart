

import 'package:test/test.dart';
import 'package:ngcompiler/v1/src/compiler/output/output_ast.dart' as o;
import 'package:ngcompiler/v1/src/compiler/view_compiler/provider_forest.dart';

void main() {
  final a = ProviderInstance([], o.nullExpr);
  final b = ProviderInstance([], o.nullExpr);
  final c = ProviderInstance([], o.nullExpr);
  final d = ProviderInstance([], o.nullExpr);

  test('expanding nothing should yield nothing', () {
    expandEmptyNodes([], []);
  });

  group('expanding empty nodes', () {
    test('should yield nothing', () {
      expandEmptyNodes([ProviderNode(0, 10)], []);
    });

    test('should yield the children', () {
      expandEmptyNodes([
        ProviderNode(0, 10, children: [
          ProviderNode(1, 5, providers: [a, b]),
          ProviderNode(6, 10, providers: [c]),
        ]),
        ProviderNode(11, 20, children: [
          ProviderNode(13, 14, children: [
            ProviderNode(14, 14, providers: [d]),
          ]),
        ]),
      ], [
        ProviderNode(1, 5, providers: [a, b]),
        ProviderNode(6, 10, providers: [c]),
        ProviderNode(14, 14, providers: [d]),
      ]);
    });
  });

  group('expanding non-empty nodes', () {
    test('should do nothing', () {
      expandEmptyNodes([
        ProviderNode(0, 10, providers: [a, b])
      ], [
        ProviderNode(0, 10, providers: [a, b])
      ]);
    });

    test('should remove empty children', () {
      expandEmptyNodes([
        ProviderNode(0, 10, providers: [
          a,
          b,
        ], children: [
          ProviderNode(1, 5, children: [
            ProviderNode(3, 3),
          ]),
          ProviderNode(6, 8),
        ])
      ], [
        ProviderNode(0, 10, providers: [a, b]),
      ]);
    });

    test('should remove empty intermediate nodes', () {
      expandEmptyNodes([
        ProviderNode(4, 16, providers: [
          a
        ], children: [
          ProviderNode(5, 16, children: [
            ProviderNode(8, 10, providers: [b, c]),
          ]),
        ]),
      ], [
        ProviderNode(4, 16, providers: [
          a
        ], children: [
          ProviderNode(8, 10, providers: [b, c]),
        ]),
      ]);
    });
  });
}

void expandEmptyNodes(List<ProviderNode> input, List<ProviderNode> expected) {
  final output = ProviderForest.expandEmptyNodes(input);
  expect(output, expected);
}
