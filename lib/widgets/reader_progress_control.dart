import 'package:focus_news/viewmodels/reader_viewmodel.dart';
import 'package:flutter/material.dart';

class ReaderProgressControl extends StatelessWidget {
  final ReaderViewModel viewModel;

  const ReaderProgressControl({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // 프리미엄 사용자이고, 일시정지 상태일 때만 슬라이더를 표시
    final bool showScrubber = viewModel.isPremiumUser && !viewModel.isPlaying;

    return Column(
      children: [
        if (showScrubber)
          Slider(
            value: (viewModel.currentWordIndex - 1)
                .toDouble()
                .clamp(0.0, (viewModel.wordCount - 1).toDouble()),
            min: 0,
            max: (viewModel.wordCount - 1).toDouble(),
            onChanged: (value) {
              viewModel.scrubToWord(value.toInt());
            },
          )
        else
          LinearProgressIndicator(
            value: viewModel.progress,
            backgroundColor: Colors.grey.shade300,
            color: Theme.of(context).colorScheme.primary,
            minHeight: 6,
          ),
        const SizedBox(height: 8),
        Text(
          '${viewModel.currentWordIndex} / ${viewModel.wordCount}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}