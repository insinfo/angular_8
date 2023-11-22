
import '../../ast.dart';
import 'attribute_ast_mixin.dart';

class SyntheticAttributeAst extends SyntheticTemplateAst with AttributeAst {
  @override
  final String name;

  @override
  final String? value;

  @override
  final List<InterpolationAst>? mustaches;

  @override
  String? get quotedValue => value == null ? null : '"$value"';

  SyntheticAttributeAst(this.name, [this.value, this.mustaches]);

  SyntheticAttributeAst.from(
    TemplateAst origin,
    this.name, [
    this.value,
    this.mustaches,
  ]) : super.from(origin);
}
