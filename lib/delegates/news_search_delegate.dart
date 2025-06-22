import 'package:focus_news/services/search_history_service.dart';
import 'package:flutter/material.dart';

class NewsSearchDelegate extends SearchDelegate<String> {
  final SearchHistoryService _historyService = SearchHistoryService();
  List<String> _searchHistory = [];
  bool _isHistoryLoaded = false;

  NewsSearchDelegate() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _searchHistory = await _historyService.getSearchHistory();
    _isHistoryLoaded = true;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (!_isHistoryLoaded) {
      _loadHistory().then((_) {
        showSuggestions(context);
      });
      return const Center(child: CircularProgressIndicator());
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final suggestionList = query.isEmpty
            ? _searchHistory
            : _searchHistory
            .where((history) => history.startsWith(query))
            .toList();

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
                padding:
                const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '최근 검색어',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        _historyService.clearSearchHistory().then((_) {
                          setState(() {
                            _searchHistory.clear();
                          });
                        });
                      },
                      child: const Text('전체 삭제'),
                    ),
                  ],
                ),
              ),
            if (_searchHistory.isNotEmpty && query.isEmpty)
              const Divider(height: 1),
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
                        _historyService.removeSearchTerm(suggestion).then((_) {
                          setState(() {
                            _searchHistory.remove(suggestion);
                          });
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
      },
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

  // ★★★ 여기가 수정된 부분입니다 ★★★
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 현재 테마의 색상을 사용하여 검색창 테마를 설정합니다.
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: colorScheme.surface, // 배경색
        foregroundColor: colorScheme.onSurface, // 아이콘 및 텍스트 색상
        surfaceTintColor: Colors.transparent, // 스크롤 시 색상 변경 방지
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        border: InputBorder.none,
      ),
    );
  }
}