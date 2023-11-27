import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';
import 'synthetic_attribute_ast.dart';


const _listEquals = ListEquality<dynamic>();

/// Represents a static attribute assignment (i.e. not bound to an expression).
///
/// Clients should not extend, implement, or mix-in this class.
abstract mixin class AttributeAst implements TemplateAst {
  /// Create a new synthetic [AttributeAst] with a string [value].
  factory AttributeAst(
    String name, [
    String? value,
    List<InterpolationAst>? mustaches,
  ]) = SyntheticAttributeAst;

  /// Create a new synthetic [AttributeAst] that originated from node [origin].
  factory AttributeAst.from(
    TemplateAst origin,
    String name, [
    String? value,
    List<InterpolationAst>? mustaches,
  ]) = SyntheticAttributeAst.from;

  /// Create a new [AttributeAst] parsed from tokens from [sourceFile].
  factory AttributeAst.parsed(
    SourceFile sourceFile,
    NgToken nameToken, [
    NgAttributeValueToken? valueToken,
    NgToken? equalSignToken,
    List<InterpolationAst>? mustaches,
  ]) = ParsedAttributeAst;

  @override
  R accept<R, C>(TemplateAstVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  bool operator ==(Object? other) {
    return other is AttributeAst &&
        name == other.name &&
        value == other.value &&
        _listEquals.equals(mustaches, other.mustaches);
  }

  @override
  int get hashCode => Object.hash(name, value);

  /// Static attribute name.
  String get name;

  /// Static attribute value; may be `null` to have no value.
  String? get value;

  /// Mustaches found within value; may be `null` if value is null.
  /// If value exists but has no mustaches, will be empty list.
  List<InterpolationAst>? get mustaches;

  /// Static attribute value with quotes attached;
  /// may be `null` to have no value.
  String? get quotedValue;

  @override
  String toString() {
    if (quotedValue != null) {
      return '$AttributeAst {$name=$quotedValue}';
    }
    return '$AttributeAst {$name}';
  }
}