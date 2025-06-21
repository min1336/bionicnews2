import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/services/bionic_reading_service.dart';
import 'package:bionic_news/viewmodels/reader_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReaderScreen extends StatelessWidget {
  final NewsArticle article;

  const ReaderScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReaderViewModel(article.content), // content 필드에 url이 저장되어 있음
      child: Consumer<ReaderViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(article.sourceName, style: const TextStyle(fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  tooltip: '원본 기사 보기',
                  onPressed: () async {
                    final url = Uri.parse(article.content);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('브라우저를 열 수 없습니다: ${article.content}')),
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
        // 기사 제목
        Text(
          article.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // 바이오닉 리딩 뷰
        Expanded(
          child: Center(
            child: BionicReadingService.getBionicText(
              viewModel.currentWord,
              style: const TextStyle(fontSize: 36),
            ),
          ),
        ),
        // 진행 상태
        const SizedBox(height: 24),
        Column(
          children: [
            LinearProgressIndicator(
              value: viewModel.progress,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blueGrey,
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

  Widget _buildBottomControls(BuildContext context, ReaderViewModel viewModel) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 속도 느리게
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: '느리게',
                  onPressed: viewModel.isLoading || viewModel.isFinished
                      ? null
                      : () => viewModel.changeSpeed(-50),
                ),
                Text('${viewModel.wpm} WPM', style: const TextStyle(fontSize: 12))
              ],
            ),
            // 재생/일시정지/재시작
            IconButton(
              iconSize: 50,
              icon: viewModel.isFinished
                  ? const Icon(Icons.replay_circle_filled_outlined, color: Colors.blueGrey)
                  : Icon(viewModel.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              tooltip: viewModel.isFinished ? '재시작' : (viewModel.isPlaying ? '일시정지' : '재생'),
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                if (viewModel.isFinished) {
                  viewModel.loadArticleContent(article.content, isRestart: true);
                } else {
                  viewModel.togglePlayPause();
                }
              },
            ),
            // 속도 빠르게
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