/// Maps application URLs into application states, to support deep-linking and
/// navigation.
library ngrouter;

export 'src/dependencies/ngrouter/src/constants.dart'
    show
        routerDirectives,
        routerProviders,
        routerProvidersHash,
        routerModule,
        routerHashModule;
export 'src/dependencies/ngrouter/src/directives/router_link_active_directive.dart' show RouterLinkActive;
export 'src/dependencies/ngrouter/src/directives/router_link_directive.dart' show RouterLink;
export 'src/dependencies/ngrouter/src/directives/router_outlet_directive.dart' show RouterOutlet;
export 'src/dependencies/ngrouter/src/lifecycle.dart';
export 'src/dependencies/ngrouter/src/location.dart';
export 'src/dependencies/ngrouter/src/route_definition.dart' show RouteDefinition;
export 'src/dependencies/ngrouter/src/route_path.dart' show RoutePath;
export 'src/dependencies/ngrouter/src/router/navigation_params.dart' show NavigationParams;
export 'src/dependencies/ngrouter/src/router/router.dart' show Router, NavigationResult;
export 'src/dependencies/ngrouter/src/router/router_state.dart' show RouterState;
export 'src/dependencies/ngrouter/src/router_hook.dart' show RouterHook;
