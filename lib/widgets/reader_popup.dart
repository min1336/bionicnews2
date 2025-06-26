import 'package:focus_news/main.dart';
import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/screens/paywall_screen.dart';
import 'package:focus_news/services/focus_reading_service.dart';
import 'package:focus_news/viewmodels/bookmark_viewmodel.dart';
import 'package:focus_news/viewmodels/reader_viewmodel.dart';
import 'package:focus_news/viewmodels/settings_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:focus_news/widgets/reader_progress_control.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReaderPopup extends StatelessWidget {
  final NewsArticle article;

  const ReaderPopup({super.key, required this.article});

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
        articleUrl: article.articleUrl,
        initialWpm: settingsViewModel.wpm,
        initialSaccadeRatio: settingsViewModel.saccadeRatio,
        initialEmphasisColor: settingsViewModel.emphasisColor,
        onWpmChanged: (newWpm) => settingsViewModel.updateWpm(newWpm),
        onSaccadeRatioChanged: (newRatio) =>
            settingsViewModel.updateSaccadeRatio(newRatio),
        isPremiumUser: userViewModel.isPremium,
        adService: adService,
      ),
      child: Consumer<ReaderViewModel>(
        builder: (context, viewModel, child) {
          final brightness = Theme.of(context).brightness;
          final normalTextColor =
          brightness == Brightness.dark ? Colors.white : Colors.black;

          final textStyle = GoogleFonts.getFont(
            settingsViewModel.fontFamily,
            fontSize: 28,
          );

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: const TextStyle(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
              ],
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
                      child: FocusReadingService.getBionicText(
                        viewModel.currentWord,
                        style: textStyle,
                        emphasisColor: viewModel.emphasisColor,
                        normalTextColor: normalTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ★★★ 여기가 수정된 부분입니다 ★★★
                  ReaderProgressControl(viewModel: viewModel),
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
                    viewModel.loadArticleContent(article.articleUrl,
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