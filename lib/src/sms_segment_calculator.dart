import '../message_segment_calculator.dart'; // Ensure this path matches where your encoding maps are defined.

/// A calculator for determining the number of SMS segments required for a given message.
/// This class provides tools to account for both standard GSM encoding and UCS-2 encoding
/// when special characters or emojis are present in the message.
class SMSegmentCalculator {
  /// The maximum number of characters allowed in a single SMS segment using GSM encoding.
  static const int GSM_SINGLE_SEGMENT_LIMIT = 160;

  /// The maximum number of characters allowed in a single SMS segment using UCS-2 encoding.
  static const int UCS2_SINGLE_SEGMENT_LIMIT = 70;

  /// The maximum number of characters in a concatenated SMS segment using GSM encoding.
  /// Concatenated messages are used when the message exceeds the limit for a single SMS
  /// and need to be split into multiple segments.
  static const int CONCATENATED_GSM_SEGMENT_LIMIT = 153;

  /// The maximum number of characters in a concatenated SMS segment using UCS-2 encoding.
  /// This limit accounts for the additional header information required to piece the segments
  /// together in the correct order when the message is received.
  static const int CONCATENATED_UCS2_SEGMENT_LIMIT = 67;

  /// Calculates the number of segments required to send a given message and the total
  /// character count of the message, considering whether it requires GSM or UCS-2 encoding.
  ///
  /// The function checks each character of the message to determine the appropriate encoding
  /// and then calculates the segment count based on the message length and encoding requirements.
  ///
  /// Returns a tuple containing the total number of segments and the character count.
  ///
  /// [message] - The SMS message for which segments are being calculated.
  /// Returns a [Tuple] where:
  /// - `totalSegments` is the number of segments.
  /// - `characterCount` is the total character count.
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
