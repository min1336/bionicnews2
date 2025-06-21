import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer.fromColors를 사용하여 반짝이는 효과를 적용합니다.
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목을 위한 회색 박스
              Container(
                width: double.infinity,
                height: 24.0,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              // 제목 두 번째 줄을 위한 짧은 회색 박스
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 24.0,
                color: Colors.white,
              ),
              const SizedBox(height: 16.0),
              // 날짜를 위한 더 짧은 회색 박스
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 16.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}