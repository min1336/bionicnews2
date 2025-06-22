import 'package:focus_news/viewmodels/topic_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_news/screens/paywall_screen.dart';

class EditTopicsScreen extends StatelessWidget {
  const EditTopicsScreen({super.key});

  void _showUpgradeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('프리미엄 기능'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PaywallScreen(),
                  fullscreenDialog: true,
                ));
              },
              child: const Text('업그레이드'),
            )
          ],
        );
      },
    );
  }

  // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터를 받도록 변경 ★★★
  void _showAddTopicDialog(
      BuildContext context, TopicViewModel viewModel, bool isPremium) {
    final TextEditingController controller = TextEditingController();
    final availableTopics = viewModel.allAvailableTopics
        .where((topic) => !viewModel.userTopics.contains(topic))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void handleAddTopic(String topic) {
              final text = topic.trim();
              if (text.isNotEmpty) {
                if (viewModel.userTopics.contains(text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이미 추가된 주제입니다: "$text"')),
                  );
                } else {
                  viewModel.addTopic(text);
                  if (context.mounted) Navigator.of(context).pop();
                }
              }
            }

            return AlertDialog(
              title: const Text('관심 주제 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ★★★ 여기가 수정된 부분입니다: 프리미엄 사용자에게만 TextField 표시 ★★★
                    if (isPremium) ...[
                      Row(
                        children: [
                          const Text('직접 입력'),
                          const SizedBox(width: 4),
                          Icon(Icons.star,
                              size: 16, color: Colors.amber.shade700),
                        ],
                      ),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: '원하는 키워드를 입력하세요...',
                        ),
                        onChanged: (text) => setState(() {}),
                        onSubmitted: handleAddTopic,
                      ),
                      if (availableTopics.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                          child: Divider(),
                        ),
                    ],
                    if (availableTopics.isNotEmpty) ...[
                      const Text('추천 주제'),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: availableTopics.map((topic) {
                          return ActionChip(
                            label: Text(topic),
                            onPressed: () => handleAddTopic(topic),
                          );
                        }).toList(),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                // ★★★ 여기가 수정된 부분입니다: 프리미엄 사용자에게만 '추가' 버튼 표시 ★★★
                if (isPremium)
                  FilledButton(
                    onPressed: controller.text.trim().isNotEmpty
                        ? () => handleAddTopic(controller.text)
                        : null,
                    child: const Text('추가'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();

    return Consumer<TopicViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('관심 주제 편집'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '주제 추가',
                onPressed: () {
                  if (!userViewModel.isPremium &&
                      viewModel.userTopics.length >= 7) {
                    _showUpgradeDialog(context,
                        '무료 사용자는 관심 주제를 최대 7개까지 추가할 수 있습니다. 더 많은 주제를 추가하려면 프리미엄으로 업그레이드하세요.');
                  } else {
                    // ★★★ 여기가 수정된 부분입니다: isPremium 상태 전달 ★★★
                    _showAddTopicDialog(context, viewModel, userViewModel.isPremium);
                  }
                },
              ),
            ],
          ),
          body: ReorderableListView.builder(
            itemCount: viewModel.userTopics.length,
            itemBuilder: (context, index) {
              final topic = viewModel.userTopics[index];
              return Card(
                key: ValueKey(topic),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(topic),
                  leading: const Icon(Icons.drag_handle),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () {
                      viewModel.removeTopic(topic);
                    },
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              viewModel.reorderTopics(oldIndex, newIndex);
            },
          ),
        );
      },
    );
  }
}