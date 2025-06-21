import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/screens/paywall_screen.dart';
import 'package:focus_news/services/focus_reading_service.dart'; // 수정된 import
import 'package:focus_news/viewmodels/bookmark_viewmodel.dart';
import 'package:focus_news/viewmodels/reader_viewmodel.dart';
import 'package:focus_news/viewmodels/settings_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReaderScreen extends StatelessWidget {
  final NewsArticle article;

  const ReaderScreen({
    super.key,
    required this.article,
  });

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

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.read<SettingsViewModel>();
    final bookmarkViewModel = context.watch<BookmarkViewModel>();
    final userViewModel = context.read<UserViewModel>();
    final isBookmarked = bookmarkViewModel.isBookmarked(article);

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
          return Scaffold(
            appBar: AppBar(
              title:
              Text(article.sourceName, style: const TextStyle(fontSize: 16)),
              actions: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.star : Icons.star_border,
                    color: isBookmarked ? Colors.amber : null,
                  ),
                  tooltip: isBookmarked ? '북마크 해제' : '북마크 추가',
                  onPressed: () {
                    if (isBookmarked) {
                      bookmarkViewModel.removeBookmark(article);
                    } else {
                      if (!userViewModel.isPremium &&
                          bookmarkViewModel.bookmarks.length >= 5) {
                        _showUpgradeDialog(context,
                            '무료 사용자는 북마크를 최대 5개까지 추가할 수 있습니다. 더 많은 기사를 저장하려면 프리미엄으로 업그레이드하세요.');
                      } else {
                        bookmarkViewModel.addBookmark(article);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  tooltip: '원본 기사 보기',
                  onPressed: () async {
                    final url = Uri.parse(article.content);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('브라우저를 열 수 없습니다: ${article.content}')),
                      );
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildBody(context, viewModel),
            ),
            bottomNavigationBar: _buildBottomControls(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReaderViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          article.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            // ★★★ 여기가 수정된 부분입니다: 클래스 이름 변경 ★★★
            child: FocusReadingService.getBionicText(
              viewModel.currentWord,
              style: const TextStyle(fontSize: 36),
              emphasisColor: viewModel.emphasisColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
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
        ),
      ],
    );
  }

  Widget _buildBottomControls(
      BuildContext context, ReaderViewModel viewModel) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: '느리게 (${viewModel.wpm} WPM)',
              onPressed: viewModel.isLoading || viewModel.isFinished
                  ? null
                  : () => viewModel.changeSpeed(-50),
            ),
            IconButton(
              iconSize: 50,
              icon: viewModel.isFinished
                  ? Icon(Icons.replay_circle_filled_outlined,
                  color: Theme.of(context).colorScheme.primary)
                  : Icon(viewModel.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled),
              tooltip: viewModel.isFinished
                  ? '재시작'
                  : (viewModel.isPlaying ? '일시정지' : '재생'),
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
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: '빠르게',
              onPressed: viewModel.isLoading || viewModel.isFinished
                  ? null
                  : () => viewModel.changeSpeed(50),
            ),
          ],
        ),
      ),
    );
  }
}