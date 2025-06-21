import 'package:flutter/material.dart';

// 클래스 이름 변경: BionicReadingService -> FocusReadingService
class FocusReadingService {
  // '집중 읽기'가 적용된 RichText 위젯을 반환하는 static 메서드
  static RichText getBionicText(
      String text, {
        TextStyle? style,
        double fixationSaccadeRatio = 0.5,
        Color emphasisColor = Colors.red,
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
            style: defaultStyle.copyWith(
                fontWeight: FontWeight.normal, color: Colors.black),
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