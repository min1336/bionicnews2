import 'package:flutter/material.dart';

class FocusReadingService {
  static RichText getBionicText(
      String text, {
        TextStyle? style,
        double fixationSaccadeRatio = 0.5,
        Color emphasisColor = Colors.red,
        // ★★★ 여기가 추가된 부분입니다: 일반 텍스트 색상 파라미터 ★★★
        Color normalTextColor = Colors.black,
      }) {
    final words = text.split(' ');
    List<TextSpan> textSpans = [];

    final defaultStyle = style ?? const TextStyle(fontSize: 16.0, height: 1.5);

    for (var word in words) {
      if (word.isNotEmpty) {
        int boldLength;
        final int wordLength = word.characters.length;

        if (wordLength <= 3) {
          boldLength = 1;
        } else if (wordLength <= 6) {
          boldLength = 2;
        } else {
          boldLength = 3;
        }

        if (boldLength == 0 && word.isNotEmpty) {
          boldLength = 1;
        }
        if (boldLength > wordLength) {
          boldLength = wordLength;
        }

        String boldPart = word.substring(0, boldLength);
        String normalPart = word.substring(boldLength);

        textSpans.add(
          TextSpan(
            text: boldPart,
            style: defaultStyle.copyWith(
                fontWeight: FontWeight.bold, color: emphasisColor),
          ),
        );
        textSpans.add(
          TextSpan(
            text: normalPart,
            // ★★★ 여기가 수정된 부분입니다: 하드코딩된 black 대신 파라미터 사용 ★★★
            style: defaultStyle.copyWith(
                fontWeight: FontWeight.normal, color: normalTextColor),
          ),
        );
        textSpans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}