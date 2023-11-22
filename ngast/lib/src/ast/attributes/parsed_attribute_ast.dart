import 'package:source_span/source_span.dart';

import '../../ast.dart';
import '../../token/tokens.dart';

import 'attribute_ast_mixin.dart';

/// Represents a real(non-synthetic) parsed AttributeAst. Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedAttributeAst extends TemplateAst
    with AttributeAst
    implements ParsedDecoratorAst, TagOffsetInfo {
  /// [NgToken] that represents the attribute name.
  @override
  final NgToken nameToken;

  /// [NgAttributeValueToken] that represents the attribute value. May be `null`
  /// to have no value.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token. May be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  ParsedAttributeAst(
    SourceFile sourceFile,
    this.nameToken, [
    this.valueToken,
    this.equalSignToken,
    this.mustaches,
  ]) : super.parsed(
          nameToken,
          valueToken == null ? nameToken : valueToken.rightQuote,
          sourceFile,
        );

  /// Static attribute name.
  @override
  String get name => nameToken.lexeme;

  /// Static attribute name offset.
  @override
  int get nameOffset => nameToken.offset;

  /// Static offset of equal sign; may be `null` to have no value.
  @override
  int? get equalSignOffset => equalSignToken?.offset;

  /// Static attribute value; may be `null` to have no value.
  @override
  String? get value => valueToken?.innerValue?.lexeme;

  /// Parsed static attribute parts that are mustache-expressions.
  @override
  final List<InterpolationAst>? mustaches;

  /// Static attribute value including quotes; may be `null` to have no value.
  @override
  String? get quotedValue => valueToken?.lexeme;

  /// Static attribute value offset; may be `null` to have no value.
  @override
  int? get valueOffset => valueToken?.innerValue?.offset;

  /// Static attribute value including quotes offset; may be `null` to have no
  /// value.
  @override
  int? get quotedValueOffset => valueToken?.leftQuote?.offset;

  @override
  NgToken? get prefixToken => null;

  @override
  int? get prefixOffset => null;

  @override
  NgToken? get suffixToken => null;

  @override
  int? get suffixOffset => null;
}
