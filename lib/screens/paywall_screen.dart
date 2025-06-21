import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('프리미엄 업그레이드'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '프리미엄으로\n모든 기능을 잠금 해제하세요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureTile(
                Icons.bookmark_add_outlined, '무제한 북마크', '원하는 모든 기사를 저장하세요.'),
            _buildFeatureTile(Icons.topic_outlined, '무제한 관심 주제',
                '나만의 뉴스 피드를 자유롭게 구성하세요.'),
            _buildFeatureTile(Icons.color_lens_outlined, '모든 테마 및 색상 설정',
                '원하는 색상으로 앱을 꾸며보세요.'),
            _buildFeatureTile(
                Icons.ads_click_outlined, '광고 없는 쾌적한 환경', '(광고 추가 시 제공 예정)'),
            const SizedBox(height: 32),

            // TODO: 실제 인앱결제 상품 정보와 연동 필요
            _buildPurchaseButton(
              context,
              title: '평생 이용권',
              price: '₩9,900',
              onPressed: () {
                userViewModel.upgradeToPremium();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프리미엄으로 업그레이드 되었습니다!')));
              },
            ),
            const SizedBox(height: 16),
            Text(
              '평생 이용권을 구매하시면 향후 추가되는 모든 프리미엄 기능을 광고 없이 이용할 수 있습니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text('구매 복원')),
                const Text('|'),
                TextButton(onPressed: () {}, child: const Text('이용약관')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildPurchaseButton(
      BuildContext context, {
        required String title,
        required String price,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        textStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          const SizedBox(width: 16),
          Text(price),
        ],
      ),
    );
  }
}