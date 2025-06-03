import 'package:flutter_test/flutter_test.dart';
import 'package:message_segment_calculator/src/segment_element.dart';
import 'package:message_segment_calculator/src/segmented_message.dart';
import 'package:message_segment_calculator/src/segment.dart';

void main() {
  group('SegmentedMessage Tests', () {
    test('Calculates correct segments for a simple GSM-7 message', () {
      String message = 'Hello, this is a test message!';
      SegmentedMessage segmentedMessage = SegmentedMessage(message);

      expect(segmentedMessage.segmentsCount, 1);
      expect(segmentedMessage.totalSize, lessThanOrEqualTo(1120)); // 1 segment
      expect(segmentedMessage.encoding, SmsEncoding.gsm7);
    });

    test('Calculates correct segments for a message with emojis', () {
      String message = 'Hello 😊! This message contains emojis.';
      SegmentedMessage segmentedMessage = SegmentedMessage(message);

      expect(segmentedMessage.segmentsCount, greaterThanOrEqualTo(1));
      expect(segmentedMessage.encoding, SmsEncoding.ucs2);
    });

    test('Handles UCS-2 encoding for special characters', () {
      String message = 'こんにちは世界'; // Japanese for "Hello, World"
      SegmentedMessage segmentedMessage = SegmentedMessage(message);

      expect(segmentedMessage.encoding, SmsEncoding.ucs2);
      expect(segmentedMessage.segmentsCount, greaterThanOrEqualTo(1));
    });

    test('Throws exception for incompatible GSM-7 characters', () {
      String message = 'Hello 😊!';

      expect(
        () => SegmentedMessage(message, SmsEncodingMode.gsm7),
        throwsException,
      );
    });

    test('Detects line break styles correctly', () {
      String message = 'Hello\nWorld\r\nNew Line';

      SegmentedMessage segmentedMessage = SegmentedMessage(message);

      expect(segmentedMessage.lineBreakStyle, LineBreakStyle.lfCrlf);
    });

    test('Identifies non-GSM characters', () {
      String message = 'Hello 😊!';

      SegmentedMessage segmentedMessage = SegmentedMessage(message);
      List<String?> nonGsmChars = segmentedMessage.getNonGsmCharacters();

      expect(nonGsmChars.isNotEmpty, true);
    });
  });

  group('EncodedChar Tests', () {
    test('Creates EncodedChar correctly for GSM-7 character', () {
      EncodedChar encodedChar = EncodedChar('A', SmsEncoding.gsm7);

      expect(encodedChar.isGSM7, true);
      expect(encodedChar.codeUnits?.length, 1);
      expect(encodedChar.sizeInBits(), 7);
    });

    test('Creates EncodedChar correctly for UCS-2 character', () {
      EncodedChar encodedChar = EncodedChar('😊', SmsEncoding.ucs2);

      expect(encodedChar.isGSM7, false);
      expect(encodedChar.codeUnits?.length, greaterThanOrEqualTo(1));
      expect(encodedChar.sizeInBits(), greaterThan(7));
    });
  });

  group('Segment Tests', () {
    test('Calculates free size correctly after adding characters', () {
      Segment segment = Segment();
      EncodedChar char = EncodedChar('A', SmsEncoding.gsm7);
      segment.add(char);

      expect(segment.freeSizeInBits(), lessThan(1120));
    });

    test('Adds headers correctly and manages overflow', () {
      Segment segment = Segment();
      EncodedChar char = EncodedChar('A', SmsEncoding.gsm7);
      segment.add(char);
      List<EncodedChar> overflow = segment.addHeader();

      expect(segment.hasUserDataHeader, true);
      expect(segment.elements.length, greaterThan(1)); // Includes headers
      expect(overflow, isEmpty); // No overflow if only one char added
    });
  });

  group('UserDataHeader Tests', () {
    test('Calculates size in bits correctly for UserDataHeader', () {
      UserDataHeader header = UserDataHeader();

      expect(header.sizeInBits(), 8);
    });
  });
}
