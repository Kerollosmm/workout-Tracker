//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <url_launcher_linux/url_launcher_plugin.h>

/**
 * @brief Registers the UrlLauncherPlugin with the given Flutter plugin registry on Linux.
 *
 * This function enables URL launching capabilities for Flutter applications by registering
 * the UrlLauncherPlugin with the provided plugin registry.
 *
 * @param registry Pointer to the Flutter plugin registry.
 */
void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
}
