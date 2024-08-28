import '../message_segment_calculator.dart'; // Ensure this path matches where your encoding maps are defined.

class SMSegmentCalculator {
  static const int GSM_SINGLE_SEGMENT_LIMIT = 160;
  static const int UCS2_SINGLE_SEGMENT_LIMIT = 70;
  static const int CONCATENATED_GSM_SEGMENT_LIMIT = 153;
  static const int CONCATENATED_UCS2_SEGMENT_LIMIT = 67;

  static Tuple2<int, int> calculateSegments(String message) {
    bool usesUCS2 = message.runes.any((int rune) {
      var character = String.fromCharCode(rune);
      return !smartEncodingMap.containsKey(character) &&
          !unicodeToGsm.containsKey(rune);
    });

    int segmentLimit =
        usesUCS2 ? UCS2_SINGLE_SEGMENT_LIMIT : GSM_SINGLE_SEGMENT_LIMIT;
    int concatenatedLimit = usesUCS2
        ? CONCATENATED_UCS2_SEGMENT_LIMIT
        : CONCATENATED_GSM_SEGMENT_LIMIT;

    int totalSegments;
    if (message.length <= segmentLimit) {
      totalSegments = 1;
    } else {
      totalSegments = (message.length / concatenatedLimit).ceil();
    }

    // Calculate the correct character count which is the count of runes (code points), not the length of the string
    int characterCount = message.runes.length;

    return Tuple2<int, int>(totalSegments, characterCount);
  }
}

// Helper class to handle pair values since Dart does not have a built-in Tuple type.
class Tuple2<T1, T2> {
  final T1 totalSegments;
  final T2 characterCount;

  Tuple2(this.totalSegments, this.characterCount);
}
