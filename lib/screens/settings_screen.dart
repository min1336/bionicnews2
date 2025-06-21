import 'package:bionic_news/viewmodels/settings_viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildThemeModeControl(context, viewModel),
              const Divider(height: 32),
              _buildWpmControl(context, viewModel),
              const Divider(height: 32),
              // ★★★ 여기가 수정된 부분입니다: '강조 범위' 호출 제거 ★★★
              // _buildSaccadeRatioControl(context, viewModel),
              // const Divider(height: 32),
              _buildColorSelection(
                context,
                title: '강조 색상',
                options: _defaultColorOptions,
                selectedColor: viewModel.emphasisColor,
                onColorSelected: (color) => viewModel.updateEmphasisColor(color),
              ),
              const Divider(height: 32),
              _buildColorSelection(
                context,
                title: '앱 테마 색상',
                options: _defaultColorOptions,
                selectedColor: viewModel.themeColor,
                onColorSelected: (color) => viewModel.updateThemeColor(color),
              ),
            ],
          );
        },
      ),
    );
  }

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
            onChanged: (value) {
              viewModel.updateWpm(value.round());
            },
          ),
        ),
      ],
    );
  }

  // ★★★ 여기가 수정된 부분입니다: '강조 범위' 함수 주석 처리 ★★★
  /*
  Widget _buildSaccadeRatioControl(
      BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("강조 범위", style: Theme.of(context).textTheme.titleLarge),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('단어의 약 ${(viewModel.saccadeRatio * 100).round()}% 강조'),
          subtitle: Slider(
            value: viewModel.saccadeRatio,
            min: 0.2,
            max: 0.8,
            divisions: 6,
            label: '${(viewModel.saccadeRatio * 100).round()}%',
            onChanged: (value) {
              viewModel.updateSaccadeRatio(value);
            },
          ),
        ),
      ],
    );
  }
  */

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
              child: Container(
                width: 40,
                height: 40,
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
            );
          }).toList(),
        )
      ],
    );
  }
}