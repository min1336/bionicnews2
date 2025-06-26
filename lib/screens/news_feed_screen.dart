import 'package:focus_news/delegates/news_search_delegate.dart';
import 'package:focus_news/screens/bookmark_screen.dart';
import 'package:focus_news/screens/edit_topics_screen.dart';
import 'package:focus_news/screens/search_result_screen.dart';
import 'package:focus_news/screens/settings_screen.dart';
import 'package:focus_news/viewmodels/topic_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:focus_news/widgets/news_topic_list.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false; // 광고 로딩 상태를 추적하는 플래그 추가
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userViewModel = context.watch<UserViewModel>();

    if (userViewModel.isPremium) {
      if (_bannerAd != null) {
        debugPrint("[Ad] 프리미엄 사용자로 전환됨. 배너 광고를 제거합니다.");
        _bannerAd?.dispose();
        _bannerAd = null;
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      }
    } else {
      // 무료 사용자이고, 광고가 로드되지 않았고, 로딩 중도 아닐 때만 로드 시작
      if (!_isAdLoaded && !_isAdLoading) {
        _loadBannerAd();
      }
    }
  }

  void _loadBannerAd() {
    debugPrint("[Ad] 배너 광고 로드를 시작합니다.");
    setState(() {
      _isAdLoading = true;
    });

    _bannerAd?.dispose(); // 혹시 모를 이전 광고 객체 제거

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[Ad] 배너 광고 로딩 성공: $ad');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('[Ad] 배너 광고 로딩 실패: $err');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoading = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _onSearchPressed() async {
    final String? result = await showSearch<String>(
      context: context,
      delegate: NewsSearchDelegate(),
    );

    if (result != null && result.isNotEmpty && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(query: result),
        ),
      );
    }
  }

  void _onSettingsPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _onBookmarksPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BookmarkScreen(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<String> topics) {
    return AppBar(
      title: const Text('Focus News'),
      actions: [
        IconButton(
          onPressed: _onBookmarksPressed,
          icon: const Icon(Icons.collections_bookmark_outlined),
          tooltip: '북마크',
        ),
        IconButton(
          onPressed: _onSearchPressed,
          icon: const Icon(Icons.search),
          tooltip: '뉴스 검색',
        ),
        IconButton(
          onPressed: _onSettingsPressed,
          icon: const Icon(Icons.settings_outlined),
          tooltip: '설정',
        ),
      ],
      bottom: topics.isNotEmpty
          ? TabBar(
        isScrollable: true,
        tabs: topics.map((String topic) => Tab(text: topic)).toList(),
        labelStyle:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
        tabAlignment: TabAlignment.start,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        indicatorWeight: 3,
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TopicViewModel, UserViewModel>(
      builder: (context, topicViewModel, userViewModel, child) {
        final userTopics = topicViewModel.userTopics;

        final adContainer = _isAdLoaded && _bannerAd != null
            ? Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : null;

        if (userTopics.isEmpty && !topicViewModel.isLoading) {
          return Scaffold(
            appBar: _buildAppBar(context, []),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.topic_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '관심 주제를 추가해보세요.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '설정에서 원하는 뉴스 주제를 추가하고\n나만의 뉴스 피드를 만들 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('관심 주제 편집하기'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EditTopicsScreen(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: !userViewModel.isPremium ? adContainer : null,
          );
        }

        return DefaultTabController(
          length: userTopics.length,
          child: Scaffold(
            appBar: _buildAppBar(context, userTopics),
            body: topicViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              // ★★★ 여기가 수정된 부분입니다: 불필요한 key 제거 ★★★
              children: userTopics.map((String topic) {
                return NewsTopicList(
                  key: ValueKey(topic),
                  query: topic,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}