//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <on_chain_bridge/on_chain_bridge.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) on_chain_bridge_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "OnChainBridge");
  on_chain_bridge_register_with_registrar(on_chain_bridge_registrar);
}
