import 'ast.dart';
import 'ast/attributes/attribute_ast_mixin.dart';

export 'visitors/desugar.dart';
export 'visitors/humanizing.dart';
export 'visitors/identity.dart';
export 'visitors/recursive.dart';
export 'visitors/whitespace.dart';

/// A visitor for [TemplateAst] trees that may process each node.
///
/// An implementation may return element [R], and optionally use [C] as context.
abstract class TemplateAstVisitor<R, C> {
  const TemplateAstVisitor();

  /// Visits all annotation ASTs.
  R visitAnnotation(AnnotationAst astNode, [C? context]);

  /// Visits all attribute ASTs.
  R visitAttribute(AttributeAst astNode, [C? context]);

  /// Visits all banana ASTs.
  ///
  /// **NOTE**: When de-sugared, this will never occur in a template tree.
  R visitBanana(BananaAst astNode, [C? context]);

  /// Visits all closeElement ASTS.
  R visitCloseElement(CloseElementAst astNode, [C? context]);

  /// Visits all comment ASTs.
  R visitComment(CommentAst astNode, [C? context]);

  /// Visits all container ASTs.
  R? visitContainer(ContainerAst astNode, [C? context]) {
    for (var c in astNode.childNodes) {
      c.accept<R, C?>(this, context);
    }
    return null;
  }

  /// Visits all embedded content ASTs.
  R visitEmbeddedContent(EmbeddedContentAst astNode, [C? context]);

  /// Visits all embedded template ASTs.
  R? visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [C? context]) {
    for (var a in astNode.attributes) {
      visitAttribute(a, context);
    }
    for (var c in astNode.childNodes) {
      c.accept<R, C?>(this, context);
    }
    for (var p in astNode.properties) {
      visitProperty(p, context);
    }
    for (var r in astNode.references) {
      visitReference(r, context);
    }
    return null;
  }

  /// Visits all element ASTs.
  R? visitElement(ElementAst astNode, [C? context]) {
    for (var a in astNode.attributes) {
      visitAttribute(a, context);
    }
    for (var c in astNode.childNodes) {
      c.accept<R, C?>(this, context);
    }
    for (var e in astNode.events) {
      visitEvent(e, context);
    }
    for (var p in astNode.properties) {
      visitProperty(p, context);
    }
    for (var r in astNode.references) {
      visitReference(r, context);
    }
    return null;
  }

  /// Visits all event ASTs.
  R visitEvent(EventAst astNode, [C? context]);

  /// Visits all interpolation ASTs.
  R visitInterpolation(InterpolationAst astNode, [C? context]);

  /// Visits all let-binding ASTs.
  R visitLetBinding(LetBindingAst astNode, [C? context]);

  /// Visits all property ASTs.
  R visitProperty(PropertyAst astNode, [C? context]);

  /// Visits all reference ASTs.
  R visitReference(ReferenceAst astNode, [C? context]);

  /// Visits all star ASTs.
  ///
  /// **NOTE**: When de-sugared, this will never occur in a template tree.
  R visitStar(StarAst astNode, [C? context]);

  /// Visits all text ASTs.
  R visitText(TextAst astNode, [C? context]);
}
