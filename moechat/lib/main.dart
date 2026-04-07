import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme/app_theme.dart';
import 'controllers/home_controller.dart';
import 'controllers/settings_controller.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'services/socket_service.dart';
import 'services/loading_service.dart';
import 'services/recording_service.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsController.init();

  // 调试输出：应用启动
  debugPrint('========================================');
  debugPrint('🚀 MoeChat 应用启动成功');
  debugPrint('📦 版本: 1.0.0+1');
  debugPrint('========================================');

  // 预初始化音频服务（全局常驻）
  final audioService = AudioService();
  await audioService.init();
  Get.put(audioService);

  runApp(const MoeChatApp());
}

class MoeChatApp extends StatelessWidget {
  const MoeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildThemeData(),
      initialBinding: BindingsBuilder(() {
        // 注册服务（AudioService 已在 main() 中初始化）
        Get.put(ApiService());
        Get.put(SocketService());
        Get.put(RecordingService());
        Get.put(LoadingService(), permanent: true);

        // 注册控制器
        Get.put(SettingsController());
        Get.put(HomeController());
      }),
      builder: (context, child) {
        return DefaultTextStyle.merge(
          style: AppTheme.cjkStyle(),
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}
