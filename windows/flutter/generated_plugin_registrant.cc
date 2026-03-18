//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <isar_flutter_libs/isar_flutter_libs_plugin.h>
#include <native_splash_screen_windows/native_splash_screen_windows_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  IsarFlutterLibsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("IsarFlutterLibsPlugin"));
  NativeSplashScreenWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NativeSplashScreenWindowsPluginCApi"));
}
