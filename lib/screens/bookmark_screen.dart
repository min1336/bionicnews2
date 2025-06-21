import 'package:focus_news/screens/reader_screen.dart';
import 'package:focus_news/viewmodels/bookmark_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크'),
      ),
      body: Consumer<BookmarkViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.bookmarks.isEmpty) {
            return const Center(
              child: Text(
                '북마크된 기사가 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: viewModel.bookmarks.length,
            itemBuilder: (context, index) {
              final article = viewModel.bookmarks.reversed.toList()[index];

              // ★★★ 여기가 수정된 부분입니다: Dismissible 위젯으로 감싸기 ★★★
              return Dismissible(
                // 각 항목을 고유하게 식별하기 위한 Key
                key: ValueKey(article.content),
                // 스와이프 방향 (오른쪽에서 왼쪽으로)
                direction: DismissDirection.endToStart,
                // 스와이프 동작이 완료되었을 때 호출
                onDismissed: (direction) {
                  viewModel.removeBookmark(article);
                  // 삭제 확인 SnackBar 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('북마크에서 삭제했습니다.'),
                      action: SnackBarAction(
                        label: '실행 취소',
                        onPressed: () {
                          // '실행 취소'를 누르면 다시 추가
                          viewModel.addBookmark(article);
                        },
                      ),
                    ),
                  );
                },
                // 스와이프하는 동안 항목 뒤에 표시될 배경
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(
                    Icons.delete_sweep_outlined,
                    color: Colors.white,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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