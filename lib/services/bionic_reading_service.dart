import 'package:flutter/material.dart';

class BionicReadingService {
  static RichText getBionicText(
      String text, {
        TextStyle? style,
        double fixationSaccadeRatio = 0.5, // 설정값은 긴 단어에 사용될 수 있으므로 유지
        Color emphasisColor = Colors.red,
      }) {
    final words = text.split(' ');
    List<TextSpan> textSpans = [];

    final defaultStyle = style ?? const TextStyle(fontSize: 16.0, height: 1.5);

    for (var word in words) {
      if (word.isNotEmpty) {
        // ★★★ 여기가 수정된 부분입니다: 새로운 동적 강조 로직 적용 ★★★
        int boldLength;
        final int wordLength = word.characters.length; // 유니코드 문자를 정확히 세기 위해 .characters 사용

        // 단어 길이에 따라 강조할 글자 수를 다르게 계산합니다.
        if (wordLength <= 3) {
          boldLength = 1; // 3글자 이하는 첫 글자만 강조
        } else if (wordLength <= 6) {
          boldLength = 2; // 4~6글자는 앞 두 글자만 강조
        } else {
          // 7글자 이상인 긴 단어는 앞 세 글자를 강조
          boldLength = 3;
          // 또는, 아래처럼 사용자의 설정값을 긴 단어에만 적용할 수도 있습니다.
          // boldLength = (wordLength * fixationSaccadeRatio).ceil();
        }

        // 단어의 첫 글자는 항상 굵게 표시되도록 최소값을 1로 보정합니다.
        if (boldLength == 0 && word.isNotEmpty) {
          boldLength = 1;
        }
        // 계산된 길이가 단어 전체 길이보다 길어지는 것을 방지합니다.
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