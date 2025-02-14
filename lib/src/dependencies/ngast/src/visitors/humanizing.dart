import '../ast.dart';
import '../ast/attributes/attribute_ast_mixin.dart';
import '../visitor.dart';

/// Provides a human-readable view of a template AST tree.
class HumanizingTemplateAstVisitor
    extends TemplateAstVisitor<String, StringBuffer?> {
  const HumanizingTemplateAstVisitor();

  @override
  String visitAnnotation(AnnotationAst astNode, [StringBuffer? context]) {
    return '@${astNode.name}';
  }

  @override
  String visitAttribute(AttributeAst astNode, [StringBuffer? context]) {
    if (astNode.value != null) {
      return '${astNode.name}="${astNode.value}"';
    }
    return astNode.name;
  }

  @override
  String visitBanana(BananaAst astNode, [StringBuffer? context]) {
    var name = '[(${astNode.name})]';
    if (astNode.value != null) {
      return '$name="${astNode.value}"';
    }
    return name;
  }

  @override
  String visitCloseElement(CloseElementAst astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context
      ..write('</')
      ..write(astNode.name)
      ..write('>');
    return context.toString();
  }

  @override
  String visitComment(CommentAst astNode, [StringBuffer? context]) {
    return '<!--${astNode.value}-->';
  }

  @override
  String visitContainer(ContainerAst astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('<ng-container');
    if (astNode.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.annotations.map(visitAnnotation), ' ');
    }
    if (astNode.stars.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.stars.map(visitStar), ' ');
    }
    context.write('>');
    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map((c) => c.accept(this)));
    }
    context.write('</ng-container>');
    return context.toString();
  }

  @override
  String visitElement(ElementAst astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context
      ..write('<')
      ..write(astNode.name);
    if (astNode.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.annotations.map(visitAnnotation), ' ');
    }
    if (astNode.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.attributes.map(visitAttribute), ' ');
    }
    if (astNode.events.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.events.map(visitEvent), ' ');
    }
    if (astNode.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.properties.map(visitProperty), ' ');
    }
    if (astNode.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.references.map(visitReference), ' ');
    }
    if (astNode.bananas.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.bananas.map(visitBanana), ' ');
    }
    if (astNode.stars.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.stars.map(visitStar), ' ');
    }

    if (astNode.isSynthetic) {
      context.write(astNode.isVoidElement ? '/>' : '>');
    } else {
      context.write(astNode.endToken!.lexeme);
    }

    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map((c) => c.accept(this)));
    }
    if (astNode.closeComplement != null) {
      context.write(visitCloseElement(astNode.closeComplement!));
    }
    return context.toString();
  }

  @override
  String visitEmbeddedContent(
    EmbeddedContentAst astNode, [
    StringBuffer? context,
  ]) {
    context ??= StringBuffer();
    if (astNode.selector != null) {
      context.write('<ng-content select="${astNode.selector}">');
    } else {
      context.write('<ng-content>');
    }
    context.write('</ng-content>');
    return context.toString();
  }

  @override
  String visitEmbeddedTemplate(
    EmbeddedTemplateAst astNode, [
    StringBuffer? context,
  ]) {
    context ??= StringBuffer();
    context.write('<template');
    if (astNode.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.annotations.map(visitAnnotation), ' ');
    }
    if (astNode.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.attributes.map(visitAttribute), ' ');
    }
    if (astNode.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.properties.map(visitProperty), ' ');
    }
    if (astNode.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.references.map(visitReference), ' ');
    }
    if (astNode.letBindings.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.letBindings.map(visitLetBinding), ' ');
    }
    context.write('>');
    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map((c) => c.accept(this)));
    }
    context.write('</template>');
    return context.toString();
  }

  @override
  String visitEvent(EventAst astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('(${astNode.name}');
    if (astNode.reductions.isNotEmpty) {
      context.write('.${astNode.reductions.join('.')}');
    }
    context.write(')');
    if (astNode.value != null) {
      context.write('="${astNode.value}"');
    }
    return context.toString();
  }

  @override
  String visitInterpolation(InterpolationAst astNode, [StringBuffer? context]) {
    return '{{${astNode.value}}}';
  }

  @override
  String visitLetBinding(LetBindingAst astNode, [StringBuffer? context]) {
    if (astNode.value == null) {
      return 'let-${astNode.name}';
    }
    return 'let-${astNode.name}="${astNode.value}"';
  }

  @override
  String visitProperty(PropertyAst astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('[${astNode.name}');
    if (astNode.postfix != null) {
      context.write('.${astNode.postfix}');
    }
    if (astNode.unit != null) {
      context.write('.${astNode.unit}');
    }
    context.write(']');
    if (astNode.value != null) {
      context.write('="${astNode.value}"');
    }
    return context.toString();
  }

  @override
  String visitReference(ReferenceAst astNode, [StringBuffer? context]) {
    var variable = '#${astNode.variable}';
    if (astNode.identifier != null) {
      return '$variable="${astNode.identifier}"';
    } else {
      return variable;
    }
  }

  @override
  String visitStar(StarAst astNode, [StringBuffer? context]) {
    var name = '*${astNode.name}';
    if (astNode.value != null) {
      return '$name="${astNode.value}"';
    } else {
      return name;
    }
  }

  @override
  String visitText(TextAst astNode, [StringBuffer? context]) {
    return astNode.value;
  }
}
