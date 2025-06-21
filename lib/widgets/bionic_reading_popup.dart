import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/services/bionic_reading_service.dart';
import 'package:bionic_news/viewmodels/reader_viewmodel.dart';
// ★★★ 여기가 수정된 부분입니다: 잘못된 패키지 경로를 올바른 상대 경로로 변경 ★★★
import '../viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BionicReadingPopup extends StatelessWidget {
  final NewsArticle article;

  const BionicReadingPopup({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.read<SettingsViewModel>();

    return ChangeNotifierProvider(
      create: (_) => ReaderViewModel(
        articleUrl: article.content,
        initialWpm: settingsViewModel.wpm,
        initialSaccadeRatio: settingsViewModel.saccadeRatio,
        initialEmphasisColor: settingsViewModel.emphasisColor,
        onWpmChanged: (newWpm) => settingsViewModel.updateWpm(newWpm),
        onSaccadeRatioChanged: (newRatio) =>
            settingsViewModel.updateSaccadeRatio(newRatio),
      ),
      child: Consumer<ReaderViewModel>(
        builder: (context, viewModel, child) {
          return AlertDialog(
            title: Text(
              article.title,
              style: const TextStyle(fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            content: SizedBox(
              height: 150,
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.errorMessage.isNotEmpty
                  ? Center(
                  child: Text(
                    viewModel.errorMessage,
                    textAlign: TextAlign.center,
                  ))
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: BionicReadingService.getBionicText(
                        viewModel.currentWord,
                        style: const TextStyle(fontSize: 28),
                        fixationSaccadeRatio: viewModel.saccadeRatio,
                        emphasisColor: viewModel.emphasisColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: viewModel.progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                      '${viewModel.wordCount == 0 ? 0 : viewModel.currentWordIndex} / ${viewModel.wordCount}'),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              IconButton(
                iconSize: 40,
                tooltip: viewModel.isFinished
                    ? '재시작'
                    : (viewModel.isPlaying ? '일시정지' : '재생'),
                icon: viewModel.isFinished
                    ? Icon(Icons.replay_circle_filled_outlined,
                    color: Theme.of(context).colorScheme.primary)
                    : Icon(viewModel.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled),
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                  if (viewModel.isFinished) {
                    viewModel.loadArticleContent(article.content,
                        isRestart: true);
                  } else {
                    viewModel.togglePlayPause();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}