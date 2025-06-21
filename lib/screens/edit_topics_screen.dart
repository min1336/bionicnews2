import 'package:focus_news/screens/paywall_screen.dart';
import 'package:focus_news/viewmodels/topic_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                Navigator.of(context).pop(); // 다이얼로그 닫기
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

  void _showAddTopicDialog(BuildContext context, TopicViewModel viewModel) {
    final availableTopics = viewModel.allAvailableTopics
        .where((topic) => !viewModel.userTopics.contains(topic))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('관심 주제 추가'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableTopics.length,
              itemBuilder: (BuildContext context, int index) {
                final topic = availableTopics[index];
                return ListTile(
                  title: Text(topic),
                  onTap: () {
                    viewModel.addTopic(topic);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            )
          ],
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
                    _showAddTopicDialog(context, viewModel);
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
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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