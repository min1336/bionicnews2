import 'package:flutter/material.dart';
import '../widgets/news_topic_list.dart'; // 방금 만든 위젯 import

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  // 탭에 표시할 토픽 목록 정의
  final List<String> _topics = ['IT/과학', '경제', '생활/문화', '정치', '세계', '스포츠'];

  @override
  Widget build(BuildContext context) {
    // DefaultTabController가 TabBar와 TabBarView를 연결하고 관리합니다.
    return DefaultTabController(
      length: _topics.length, // 탭의 개수
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bionic Reading 뉴스피드'),
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
          // AppBar의 bottom 영역에 TabBar를 추가
          bottom: TabBar(
            isScrollable: true, // 탭이 많을 경우 스크롤 가능
            tabs: _topics.map((String topic) {
              return Tab(text: topic);
            }).toList(),
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            tabAlignment: TabAlignment.start, // 탭을 왼쪽부터 정렬
            indicatorColor: Colors.lightBlueAccent,
            indicatorWeight: 3,
          ),
        ),
        // TabBarView는 각 탭에 해당하는 화면을 보여줍니다.
        body: TabBarView(
          children: _topics.map((String topic) {
            // 각 토픽에 맞는 NewsTopicList 위젯을 생성
            return NewsTopicList(query: topic);
          }).toList(),
        ),
      ),
    );
  }
}