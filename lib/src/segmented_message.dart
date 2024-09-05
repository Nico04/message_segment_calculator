import 'package:characters/characters.dart';
import 'package:message_segment_calculator/message_segment_calculator.dart';
import 'package:message_segment_calculator/src/enchoded_char.dart';

import 'segments.dart';

enum SmsEncoding { gsm7, ucs2, auto }

enum validEncodingValues { gsm7, ucs2, auto }

enum LineBreakStyle {
  /// Represents 'LF'
  lf,

  /// Represents 'CRLF'
  crlf,

  /// Represents 'LF+CRLF'
  lfCrlf,

  undefined
}

class SegmentedMessage {
  SmsEncoding encoding = SmsEncoding.auto;
  List<Segment> segments = [];
  List<String> graphemes = [];
  int numberOfUnicodeScalars = 0;
  int numberOfCharacters = 0;
  List<EncodedChar> encodedChars = [];
  LineBreakStyle? lineBreakStyle;
  List<String> warnings = [];

  SegmentedMessage(String message,
      [SmsEncoding encoding = SmsEncoding.auto, bool smartEncoding = false])
      : encoding = encoding {
    if (!validEncodingValues.values.any((e) => e.name == encoding.name)) {
      throw ('Encoding $encoding not supported',);
    }

    if (smartEncoding) {
      message = message
          .split('')
          .map((char) =>
              smartEncodingMap[char] ??
              char) // Use `??` to provide a fallback if SmartEncodingMap[char] is null
          .join('');
    }
    graphemes = splitGraphemes(message);

    numberOfUnicodeScalars = message.runes.length;

    // // Encode characters

    String? encodingName;
    if (encoding == SmsEncoding.auto) {
      encodingName = _hasAnyUCSCharacters(graphemes) ? 'ucs2' : 'gsm7';
    } else {
      if (encoding == SmsEncoding.gsm7 && _hasAnyUCSCharacters(graphemes)) {
        throw ('The string provided is incompatible with GSM-7 encoding');
      }

      encodingName = encoding.name;
    }

    encodedChars = _encodeChars(graphemes);
    // // Determine encoding based on character content
    // this.encoding = _determineEncoding(encodedChars);

    numberOfCharacters = encodingName == SmsEncoding.ucs2.name
        ? graphemes.length
        : _countCodeUnits(encodedChars);
    segments = _buildSegments(encodedChars);
    lineBreakStyle = _detectLineBreakStyle(message);
    warnings = _checkForWarnings(lineBreakStyle);
  }

  // Method to convert each character to its encoded representation
  List<EncodedChar> _encodeChars(List<String> graphemes) {
    List<EncodedChar> encodedChars = [];

    for (String grapheme in graphemes) {
      encodedChars.add(EncodedChar(grapheme, encoding.name));
    }

    return encodedChars;
  }

  /// Determine encoding for the entire message
  SmsEncoding _determineEncoding(List<EncodedChar> encodedChars) {
    // If any character is not GSM-7, use UCS-2 encoding for the entire message
    bool hasNonGSMCharacter =
        encodedChars.any((encodedChar) => !(encodedChar.isGSM7 ?? false));
    return hasNonGSMCharacter ? SmsEncoding.ucs2 : SmsEncoding.gsm7;
  }

  List<Segment> _buildSegments(List<EncodedChar> encodedChars) {
    // Initialize segments list and add the first segment
    List<Segment> segments = [];
    segments.add(Segment());
    Segment currentSegment = segments[0];

    // Iterate over each encoded character
    for (EncodedChar encodedChar in encodedChars) {
      // Check if adding the current character exceeds the free size of the current segment
      if (currentSegment.freeSizeInBits() < encodedChar.sizeInBits()) {
        // Add a new segment with a user data header
        segments.add(Segment(withUserDataHeader: true));
        currentSegment = segments[segments.length - 1];
        Segment previousSegment = segments[segments.length - 2];

        // Check if the previous segment has a user data header; if not, add it
        if (!previousSegment.hasUserDataHeader) {
          List<EncodedChar> removedChars = previousSegment.addHeader();

          // Add removed characters from the previous segment to the current segment
          for (EncodedChar char in removedChars) {
            currentSegment.add(char);
          }
        }
      }
      // Add the encoded character to the current segment
      currentSegment.add(encodedChar);
    }

    return segments;
  }

  int _countCodeUnits(List<EncodedChar> encodedChars) {
    return encodedChars.fold<int>(
      0,
      (int accumulator, EncodedChar nextEncodedChar) =>
          accumulator + nextEncodedChar.codeUnits!.length,
    );
  }

  /// Calculate total size in bits of the entire message
  // int get totalSize =>
  //     segments.fold(0, (total, segment) => total + segment.sizeInBits());

  int get totalSize {
    int size = 0;
    for (Segment segment in segments) {
      size += segment.sizeInBits();
    }
    return size;
  }

  /// Calculate message size in bits, excluding any user data headers
  int get messageSize {
    int size = 0;

    // Iterate over each segment and add its size in bits
    for (var segment in segments) {
      size += segment.messageSizeInBits();
    }

    return size;
  }

  int get segmentsCount => segments.length;

  List<String?> getNonGsmCharacters() {
    return encodedChars
        .where((encodedChar) =>
            !(encodedChar.isGSM7 ?? false)) // Filter non-GSM7 characters
        .map((encodedChar) => encodedChar.raw) // Map to raw character
        .toList();
  }

  LineBreakStyle? _detectLineBreakStyle(String message) {
    bool hasWindowsStyle = message.contains('\r\n');
    bool hasUnixStyle = message.contains('\n');
    bool mixedStyle = hasWindowsStyle && hasUnixStyle;
    bool noBreakLine = !hasWindowsStyle && !hasUnixStyle;

    if (noBreakLine) {
      return null;
    }
    if (mixedStyle) {
      return LineBreakStyle.lfCrlf;
    }
    return hasUnixStyle ? LineBreakStyle.lf : LineBreakStyle.crlf;
  }

  List<String> _checkForWarnings(LineBreakStyle? lineBreakStyle) {
    List<String> warnings = [];

    // Check if lineBreakStyle is present
    if (lineBreakStyle != null) {
      warnings.add(
        'The message has line breaks, the web page utility only supports LF style. If you insert a CRLF it will be converted to LF.',
      );
    }

    return warnings;
  }

  List<String> splitGraphemes(String message) {
    // Use the characters package to split the message into graphemes
    return message.characters.fold<List<String>>([], (accumulator, grapheme) {
      // Check if the grapheme is a carriage return + line feed
      if (grapheme == '\r\n') {
        accumulator.addAll(
            grapheme.split('')); // Split '\r\n' into separate characters
      } else {
        accumulator.add(grapheme); // Add the grapheme as is
      }
      return accumulator;
    });
  }

  bool _hasAnyUCSCharacters(List<String> graphemes) {
    bool result = false;

    for (String grapheme in graphemes) {
      // Check if the grapheme requires UCS-2 encoding
      if (grapheme.length >= 2 ||
          (grapheme.length == 1 &&
              !unicodeToGsm.containsKey(grapheme.codeUnitAt(0)))) {
        result = true;
        break;
      }
    }

    return result;
  }
}
