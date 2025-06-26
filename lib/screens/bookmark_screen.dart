import 'package:focus_news/screens/reader_screen.dart';
import 'package:focus_news/viewmodels/bookmark_viewmodel.dart';
import 'package:focus_news/widgets/error_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크'),
      ),
      body: Consumer<BookmarkViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ★★★ 여기가 추가된 부분입니다: 오류 처리 UI ★★★
          if (viewModel.hasError) {
            return ErrorDisplayWidget(
              errorMessage: viewModel.errorMessage,
              onRetry: () => viewModel.loadBookmarks(),
            );
          }

          if (viewModel.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_remove_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '북마크된 기사가 없습니다.',
                    style: textTheme.headlineSmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '기사 읽기 화면에서 별(★) 아이콘을 눌러\n중요한 기사를 저장해보세요.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: viewModel.bookmarks.length,
            itemBuilder: (context, index) {
              final article = viewModel.bookmarks.reversed.toList()[index];

              return Dismissible(
                key: ValueKey(article.articleUrl),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  viewModel.removeBookmark(article);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('북마크에서 삭제했습니다.'),
                      action: SnackBarAction(
                        label: '실행 취소',
                        onPressed: () {
                          viewModel.addBookmark(article);
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  color: colorScheme.errorContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.delete_sweep_outlined,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      article.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        article.formattedPubDate,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(
                            article: article,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}