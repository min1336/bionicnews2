import 'package:flutter/material.dart';

class BionicReadingService {
  // 텍스트를 받아 바이오닉 리딩이 적용된 RichText 위젯을 반환하는 static 메서드
  static RichText getBionicText(String text, {TextStyle? style}) {
    // 텍스트를 공백 기준으로 단어들로 분리합니다.
    final words = text.split(' ');
    List<TextSpan> textSpans = [];

    // 기본 텍스트 스타일
    final defaultStyle = style ?? const TextStyle(fontSize: 16.0, height: 1.5);

    for (var word in words) {
      if (word.isNotEmpty) {
        // 단어 길이의 약 40%를 굵게 처리할 지점으로 계산합니다.
        // ceil()을 사용하여 소수점을 올림 처리합니다.
        int boldLength = (word.length * 0.4).ceil();

        // 굵게 표시할 부분
        String boldPart = word.substring(0, boldLength);
        // 일반 텍스트로 표시할 부분
        String normalPart = word.substring(boldLength);

        textSpans.add(
          TextSpan(
            text: boldPart,
            style: defaultStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        );
        textSpans.add(
          TextSpan(
            text: normalPart,
            // 기본 스타일 위에 색상은 검은색, 굵기는 보통으로 명확히 지정
            style: defaultStyle.copyWith(fontWeight: FontWeight.normal, color: Colors.black),
          ),
        );
        // 단어 사이에 공백 추가
        textSpans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}