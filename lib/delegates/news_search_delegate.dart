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
        // Use showSuggestions to trigger a rebuild once history is loaded.
        // This part is tricky, and a direct state update is better if possible.
        // For now, keeping the original logic for initial load.
        showSuggestions(context);
      });
      return const Center(child: CircularProgressIndicator());
    }

    // ★★★ 여기가 수정된 부분입니다: StatefulBuilder로 감싸기 ★★★
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
                        // 전체 삭제
                        _historyService.clearSearchHistory().then((_) {
                          // ★★★ 여기가 수정된 부분입니다: setState 호출 ★★★
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
                        // 개별 삭제
                        _historyService.removeSearchTerm(suggestion).then((_) {
                          // ★★★ 여기가 수정된 부분입니다: setState 호출 ★★★
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