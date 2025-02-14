import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/ir/model.dart' as ir;

/// Combines multiple [ir.EventHandlers] together as an optimization.
///
/// In the case that multiple bindings on a directive or element target the same
/// event name, we can merge these handlers into a single method.
List<ir.Binding> mergeEvents(List<ir.Binding> events) {
  final visitedEvents = <String, ir.Binding>{};
  for (var event in events) {
    var eventName = (event.target as ir.BoundEvent).name;
    var handler = visitedEvents[eventName];
    if (handler == null) {
      visitedEvents[eventName] = event;
      continue;
    }
    visitedEvents[eventName] = _merge(handler, event);
  }
  return visitedEvents.values.toList();
}

ir.Binding _merge(ir.Binding handler, ir.Binding event) => ir.Binding(
    target: handler.target,
    source: (handler.source as ir.EventHandler)
        .merge(event.source as ir.EventHandler));
