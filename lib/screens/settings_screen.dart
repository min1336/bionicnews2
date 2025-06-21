import 'package:focus_news/screens/edit_topics_screen.dart';
import 'package:focus_news/screens/paywall_screen.dart';
import 'package:focus_news/viewmodels/settings_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Color> _defaultColorOptions = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.blueGrey,
    Colors.black,
  ];

  // 프리미엄 기능 안내를 위한 SnackBar 표시 함수
  void _showPremiumFeatureSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('프리미엄 사용자 전용 기능입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Consumer2<SettingsViewModel, UserViewModel>(
        builder: (context, settingsViewModel, userViewModel, child) {
          if (settingsViewModel.isLoading || userViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isPremium = userViewModel.isPremium;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSubscriptionStatus(context, userViewModel),
              const Divider(height: 32),
              ListTile(
                title: const Text('관심 주제 편집'),
                leading: const Icon(Icons.topic_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const EditTopicsScreen(),
                  ));
                },
              ),
              const Divider(height: 32),
              _buildThemeModeControl(context, settingsViewModel, isPremium),
              const Divider(height: 32),
              _buildWpmControl(context, settingsViewModel, isPremium),
              const Divider(height: 32),
              _buildColorSelection(
                context,
                title: '강조 색상',
                options: _defaultColorOptions,
                selectedColor: settingsViewModel.emphasisColor,
                onColorSelected: (color) =>
                    settingsViewModel.updateEmphasisColor(color),
                isPremium: isPremium,
              ),
              const Divider(height: 32),
              _buildColorSelection(
                context,
                title: '앱 테마 색상',
                options: _defaultColorOptions,
                selectedColor: settingsViewModel.themeColor,
                onColorSelected: (color) =>
                    settingsViewModel.updateThemeColor(color),
                isPremium: isPremium,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionStatus(
      BuildContext context, UserViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("구독 상태", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              viewModel.isPremium ? '프리미엄 사용자' : '무료 사용자',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: viewModel.isPremium
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (!viewModel.isPremium)
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PaywallScreen(),
                      fullscreenDialog: true,
                    ));
                  },
                  child: const Text('프리미엄으로 업그레이드'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => viewModel.revertToFree(),
                  child: const Text('무료 버전으로 돌아가기 (테스트)'),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeControl(
      BuildContext context, SettingsViewModel viewModel, bool isPremium) {
    return GestureDetector(
      onTap: isPremium ? null : () => _showPremiumFeatureSnackBar(context),
      child: AbsorbPointer(
        absorbing: !isPremium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("앱 테마", style: Theme.of(context).textTheme.titleLarge),
                if (!isPremium) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock, size: 18, color: Colors.grey.shade600)
                ],
              ],
            ),
            const SizedBox(height: 8),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정 따르기'),
              value: ThemeMode.system,
              groupValue: viewModel.themeMode,
              onChanged: isPremium
                  ? (value) {
                if (value != null) viewModel.updateThemeMode(value);
              }
                  : null,
            ),
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              value: ThemeMode.light,
              groupValue: viewModel.themeMode,
              onChanged: isPremium
                  ? (value) {
                if (value != null) viewModel.updateThemeMode(value);
              }
                  : null,
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              value: ThemeMode.dark,
              groupValue: viewModel.themeMode,
              onChanged: isPremium
                  ? (value) {
                if (value != null) viewModel.updateThemeMode(value);
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWpmControl(
      BuildContext context, SettingsViewModel viewModel, bool isPremium) {
    return GestureDetector(
      onTap: isPremium ? null : () => _showPremiumFeatureSnackBar(context),
      child: AbsorbPointer(
        absorbing: !isPremium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("읽기 속도 (WPM)", style: Theme.of(context).textTheme.titleLarge),
                if (!isPremium) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock, size: 18, color: Colors.grey.shade600)
                ],
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${viewModel.wpm}'),
              subtitle: Slider(
                value: viewModel.wpm.toDouble(),
                min: 100,
                max: 1200,
                divisions: 22,
                label: viewModel.wpm.toString(),
                onChanged:
                isPremium ? (value) => viewModel.updateWpm(value.round()) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelection(
      BuildContext context, {
        required String title,
        required List<Color> options,
        required Color selectedColor,
        required Function(Color) onColorSelected,
        required bool isPremium,
      }) {
    return GestureDetector(
      onTap: isPremium ? null : () => _showPremiumFeatureSnackBar(context),
      child: AbsorbPointer(
        absorbing: !isPremium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (!isPremium) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock, size: 18, color: Colors.grey.shade600)
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: options.map((color) {
                final isSelected = selectedColor.value == color.value;
                return GestureDetector(
                  onTap: isPremium ? () => onColorSelected(color) : null,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(isPremium ? 1.0 : 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected && isPremium
                              ? Theme.of(context).colorScheme.outline
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected && isPremium
                          ? const Icon(Icons.check,
                          color: Colors.white, size: 24)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}