import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../widgets/common/avatar_image.dart';
import 'chat_page.dart';
import 'assistant_detail_page.dart';

/// 助手列表页面 - 移动端
///
/// 显示所有AI助手的列表，类似QQ的聊天列表布局
class AssistantsPage extends StatelessWidget {
  const AssistantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: const Text('MoeChat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const AssistantDetailPage());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingAssistants.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.assistants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无助手',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击右上角添加按钮创建助手',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.assistants.length,
          itemBuilder: (context, index) {
            final assistant = controller.assistants[index];
            return ListTile(
              leading: ReactiveAvatarImage(
                assistantName: assistant.name,
                fallbackAvatar: assistant.avatar,
                size: 50,
              ),
              title: Text(
                assistant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                assistant.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                // 先切换到选中的助手
                await controller.selectAssistant(index);
                // 无论切换是否成功都进入聊天页
                // （selectAssistant 内部已处理错误提示）
                Get.to(() => const ChatPage());
              },
            );
          },
        );
      }),
    );
  }
}
