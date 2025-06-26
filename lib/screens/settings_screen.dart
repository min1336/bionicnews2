import 'package:focus_news/screens/edit_topics_screen.dart';
import 'package:focus_news/screens/paywall_screen.dart';
import 'package:focus_news/viewmodels/bookmark_viewmodel.dart';
import 'package:focus_news/viewmodels/settings_viewmodel.dart';
import 'package:focus_news/viewmodels/topic_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Color> _colorOptions = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.blueGrey,
  ];

  static const List<String> _fontOptions = [
    'Noto Sans KR',
    'Nanum Gothic',
    'Nanum Myeongjo',
    'Gaegu',
  ];

  void _showPremiumFeatureSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('프리미엄 사용자 전용 기능입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ★★★ 여기가 추가된 부분입니다: 앱 초기화 확인 다이얼로그 ★★★
  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('앱 초기화'),
          content: const Text(
              '모든 설정, 북마크, 관심 주제 등 사용자 데이터가 삭제되고 앱이 초기 상태로 돌아갑니다. 이 작업은 되돌릴 수 없습니다. 정말로 초기화하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError),
              onPressed: () {
                // 모든 ViewModel에 접근하여 데이터 리셋 및 리로드 실행
                final settingsViewModel = context.read<SettingsViewModel>();
                final userViewModel = context.read<UserViewModel>();
                final topicViewModel = context.read<TopicViewModel>();
                final bookmarkViewModel = context.read<BookmarkViewModel>();

                settingsViewModel.resetAllApplicationData().then((_) {
                  // 다른 뷰모델들도 새로운 상태를 다시 불러오도록 함
                  userViewModel.loadUserStatus();
                  topicViewModel.loadTopics();
                  bookmarkViewModel.loadBookmarks();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('앱 데이터가 초기화되었습니다.')),
                  );
                });
              },
              child: const Text('초기화'),
            ),
          ],
        );
      },
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
              // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터 제거 ★★★
              _buildThemeModeControl(context, settingsViewModel),
              const Divider(height: 32),
              _buildFontControl(context, settingsViewModel, isPremium),
              const Divider(height: 32),
              // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터 제거 ★★★
              _buildWpmControl(context, settingsViewModel),
              const Divider(height: 32),
              _buildColorSelection(
                context,
                title: '강조 색상',
                options: _colorOptions,
                selectedColor: settingsViewModel.emphasisColor,
                onColorSelected: (color) =>
                    settingsViewModel.updateEmphasisColor(color),
                // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터 제거 ★★★
              ),
              const Divider(height: 32),
              _buildColorSelection(
                context,
                title: '앱 테마 색상',
                options: _colorOptions,
                selectedColor: settingsViewModel.themeColor,
                onColorSelected: (color) =>
                    settingsViewModel.updateThemeColor(color),
                // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터 제거 ★★★
              ),
              const Divider(height: 32),
              _buildDeveloperMenu(context, userViewModel),
              _buildResetAppButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeveloperMenu(BuildContext context, UserViewModel viewModel) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 20),
                const SizedBox(width: 8),
                Text("개발자용 테스트 메뉴",
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '실제 결제 없이 프리미엄 상태를 테스트합니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => viewModel.upgradeToPremium(),
                    child: const Text('프리미엄으로 변경'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => viewModel.revertToFree(),
                    child: const Text('무료로 변경'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터와 관련 로직 제거 ★★★
  Widget _buildThemeModeControl(
      BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("앱 테마", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        RadioListTile<ThemeMode>(
          title: const Text('시스템 설정 따르기'),
          value: ThemeMode.system,
          groupValue: viewModel.themeMode,
          onChanged: (value) {
            if (value != null) viewModel.updateThemeMode(value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('라이트 모드'),
          value: ThemeMode.light,
          groupValue: viewModel.themeMode,
          onChanged: (value) {
            if (value != null) viewModel.updateThemeMode(value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('다크 모드'),
          value: ThemeMode.dark,
          groupValue: viewModel.themeMode,
          onChanged: (value) {
            if (value != null) viewModel.updateThemeMode(value);
          },
        ),
      ],
    );
  }

  Widget _buildFontControl(
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
                Text("읽기 폰트", style: Theme.of(context).textTheme.titleLarge),
                if (!isPremium) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock, size: 18, color: Colors.grey.shade600)
                ],
              ],
            ),
            const SizedBox(height: 8),
            for (String font in _fontOptions)
              RadioListTile<String>(
                title: Text(font, style: GoogleFonts.getFont(font)),
                value: font,
                groupValue: viewModel.fontFamily,
                onChanged: isPremium
                    ? (value) {
                  if (value != null) viewModel.updateFontFamily(value);
                }
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터와 관련 로직 제거 ★★★
  Widget _buildWpmControl(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("읽기 속도 (WPM)", style: Theme.of(context).textTheme.titleLarge),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${viewModel.wpm}'),
          subtitle: Slider(
            value: viewModel.wpm.toDouble(),
            min: 100,
            max: 1200,
            divisions: 22,
            label: viewModel.wpm.toString(),
            onChanged: (value) => viewModel.updateWpm(value.round()),
          ),
        ),
      ],
    );
  }

  // ★★★ 여기가 수정된 부분입니다: isPremium 파라미터와 관련 로직 제거 ★★★
  Widget _buildColorSelection(
      BuildContext context, {
        required String title,
        required List<Color> options,
        required Color selectedColor,
        required Function(Color) onColorSelected,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: options.map((color) {
            final isSelected = selectedColor.value == color.value;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.outline
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // ★★★ 여기가 추가된 부분입니다: 앱 초기화 버튼 위젯 ★★★
  Widget _buildResetAppButton(BuildContext context) {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: () => _showResetConfirmationDialog(context),
        child: const Text('앱 데이터 전체 초기화'),
      ),
    );
  }
}