import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/screens/search_result_screen.dart';
import 'package:bionic_news/services/news_api_service.dart';
import 'package:bionic_news/services/search_history_service.dart';
import 'package:flutter/material.dart';

class NewsSearchDelegate extends SearchDelegate<String> {
  final SearchHistoryService _historyService = SearchHistoryService();
  List<String> _searchHistory = [];
  bool _isHistoryLoaded = false;

  NewsSearchDelegate() {
    _loadHistory();
  }

  // 검색 기록을 비동기적으로 불러와 멤버 변수에 저장
  Future<void> _loadHistory() async {
    _searchHistory = await _historyService.getSearchHistory();
    // 기록 로드가 완료되었음을 표시
    // 이 변수는 buildSuggestions가 로딩 위젯을 표시할지 결정하는 데 사용됩니다.
    _isHistoryLoaded = true;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 기록이 아직 로드되지 않았다면, 로드를 요청하고 로딩 아이콘을 표시
    if (!_isHistoryLoaded) {
      // .then()을 사용하여 로드가 완료되면 UI를 다시 그리도록 함
      _loadHistory().then((_) {
        // SearchDelegate의 내용(suggestions)을 다시 빌드하도록 요청
        showSuggestions(context);
      });
      return const Center(child: CircularProgressIndicator());
    }

    final suggestionList = query.isEmpty
        ? _searchHistory
        : _searchHistory.where((history) => history.startsWith(query)).toList();

    if (suggestionList.isEmpty && query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '최근 검색 기록이 없습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchHistory.isNotEmpty && query.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 검색어',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // ★★★ 여기가 수정된 부분입니다 (전체 삭제) ★★★
                    _historyService.clearSearchHistory().then((_) {
                      // 저장이 완료된 후, 로컬 리스트를 비우고 UI를 갱신
                      _searchHistory.clear();
                      showSuggestions(context);
                    });
                  },
                  child: const Text('전체 삭제'),
                ),
              ],
            ),
          ),
        if (_searchHistory.isNotEmpty && query.isEmpty) const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              final suggestion = suggestionList[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(suggestion),
                trailing: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    // ★★★ 여기가 수정된 부분입니다 (개별 삭제) ★★★
                    _historyService.removeSearchTerm(suggestion).then((_) {
                      // 저장이 완료된 후, 로컬 리스트에서 제거하고 UI를 갱신
                      _searchHistory.remove(suggestion);
                      showSuggestions(context);
                    });
                  },
                ),
                onTap: () {
                  query = suggestion;
                  showResults(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      _historyService.addSearchTerm(query);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        close(context, query);
      });
    }
    return Container();
  }

  // --- 나머지 buildActions, buildLeading, appBarTheme 함수는 변경 없음 ---
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }
}