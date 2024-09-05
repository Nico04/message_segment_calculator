import 'package:grapheme_splitter/grapheme_splitter.dart';
import 'package:message_segment_calculator/message_segment_calculator.dart';
import 'package:message_segment_calculator/src/enchoded_char.dart';

import 'segments.dart';

/// =============================================================================
/// ENUM: SmsEncoding
/// PURPOSE: Specifies the encoding types that can be used for SMS messages.
/// =============================================================================
enum SmsEncoding {
  /// Represents the GSM-7 encoding, a 7-bit encoding standard used for SMS messages.
  gsm7,

  /// Represents the UCS-2 encoding, a 16-bit encoding standard used for SMS messages that include non-GSM-7 characters.
  ucs2,

  /// Automatically determines the best encoding based on the content of the SMS message.
  auto
}

/// Valid encoding values for SMS messages.
enum ValidEncodingValues {
  /// Represents the GSM-7 encoding, a 7-bit encoding standard used for SMS messages.
  gsm7,

  /// Represents the UCS-2 encoding, a 16-bit encoding standard used for SMS messages that include non-GSM-7 characters.
  ucs2,

  /// Automatically determines the best encoding based on the content of the SMS message.
  auto
}

/// =============================================================================
/// ENUM: LineBreakStyle
/// PURPOSE: Defines different styles for line breaks in text messages.
/// =============================================================================
enum LineBreakStyle {
  /// Represents 'LF' (Line Feed)
  lf,

  /// Represents 'CRLF' (Carriage Return + Line Feed)
  crlf,

  /// Represents 'LF+CRLF' (Combination of LF and CRLF)
  lfCrlf,

  /// Undefined or no line break style
  undefined
}

/// =============================================================================
/// CLASS: SegmentedMessage
/// PURPOSE: Manages the segmentation and encoding of SMS messages based on
/// specified encoding formats. It supports encoding into GSM-7 and UCS-2
/// character sets and can handle different line break styles.
/// =============================================================================
class SegmentedMessage {
  /// Encoding format for the SMS message, defaults to auto-detection
  SmsEncoding encoding = SmsEncoding.auto;

  /// List of segments created for the SMS message
  List<Segment> segments = [];

  /// List of graphemes in the message
  List<String> graphemes = [];

  /// Total number of Unicode scalars in the message
  int numberOfUnicodeScalars = 0;

  /// Total number of characters in the message
  int numberOfCharacters = 0;

  /// Encoded characters after processing the message content
  List<EncodedChar> encodedChars = [];

  /// Style of line breaks in the message
  LineBreakStyle? lineBreakStyle;

  /// List of warnings detected during message processing
  List<String> warnings = [];

  /// Constructor for the SegmentedMessage class.
  ///
  /// [message] : The message content to be segmented and encoded.
  /// [encoding] : The desired encoding format (defaults to auto-detection).
  /// [smartEncoding] : Whether to use smart encoding for character replacement.
  SegmentedMessage(String message,
      [SmsEncoding encoding = SmsEncoding.auto, bool smartEncoding = false])
      : encoding = encoding {
    GraphemeSplitter splitter = GraphemeSplitter();

    // Check if the specified encoding is valid
    if (!ValidEncodingValues.values.any((e) => e.name == encoding.name)) {
      throw ('Encoding $encoding not supported');
    }

    // Apply smart encoding if enabled
    if (smartEncoding) {
      message = message
          .split('')
          .map((char) =>
              smartEncodingMap[char] ?? char) // Fallback to original character
          .join('');
    }

    /// Split message into graphemes and process line breaks
    graphemes = splitter.splitGraphemes(message).fold<List<String>>([],
        (List<String> accumulator, String grapheme) {
      if (grapheme == '\r\n') {
        accumulator.addAll(grapheme.split('')); // Separate '\r\n' characters
      } else {
        accumulator.add(grapheme); // Add the grapheme as is
      }
      return accumulator;
    });

    /// Count the number of Unicode scalars in the message
    numberOfUnicodeScalars = message.runes.length;

    /// Determine the encoding type for the message
    String? encodingName;
    if (encoding == SmsEncoding.auto) {
      encodingName = _hasAnyUCSCharacters(graphemes) ? 'ucs2' : 'gsm7';
    } else {
      if (encoding == SmsEncoding.gsm7 && _hasAnyUCSCharacters(graphemes)) {
        throw ('The string provided is incompatible with GSM-7 encoding');
      }
      encodingName = encoding.name;
    }

    /// Encode the characters based on the determined encoding
    encodedChars = _encodeChars(graphemes, encodingName);

    /// Count the number of characters based on encoding
    numberOfCharacters = encodingName == SmsEncoding.ucs2.name
        ? graphemes.length
        : _countCodeUnits(encodedChars);

    /// Build segments from encoded characters
    segments = _buildSegments(encodedChars);

    /// Detect the line break style in the message
    lineBreakStyle = _detectLineBreakStyle(message);

    /// Check for any warnings in the message content
    warnings = _checkForWarnings(lineBreakStyle);
  }

  /// Method to encode each character in the message to its encoded representation.
  ///
  /// [graphemes] : List of graphemes in the message.
  /// [encodingName] : The encoding name ('gsm7' or 'ucs2').
  ///
  /// Returns a list of encoded characters.
  List<EncodedChar> _encodeChars(List<String> graphemes, String encodingName) {
    List<EncodedChar> encodedChars = [];

    for (String grapheme in graphemes) {
      encodedChars.add(EncodedChar(grapheme, encodingName));
    }

    return encodedChars;
  }

  /// Builds segments for the message by distributing characters into SMS segments.
  ///
  /// [encodedChars] : List of encoded characters.
  ///
  /// Returns a list of message segments.
  List<Segment> _buildSegments(List<EncodedChar> encodedChars) {
    List<Segment> segments = [];
    segments.add(Segment());
    Segment currentSegment = segments[0];

    /// Iterate over each encoded character and add it to the appropriate segment
    for (EncodedChar encodedChar in encodedChars) {
      if (currentSegment.freeSizeInBits() < encodedChar.sizeInBits()) {
        segments.add(Segment(withUserDataHeader: true));
        currentSegment = segments[segments.length - 1];
        Segment previousSegment = segments[segments.length - 2];

        if (!previousSegment.hasUserDataHeader) {
          List<EncodedChar> removedChars = previousSegment.addHeader();

          for (EncodedChar char in removedChars) {
            currentSegment.add(char);
          }
        }
      }
      currentSegment.add(encodedChar);
    }

    return segments;
  }

  /// Counts the total number of code units in the message.
  ///
  /// [encodedChars] : List of encoded characters.
  ///
  /// Returns the total number of code units.
  int _countCodeUnits(List<EncodedChar> encodedChars) {
    return encodedChars.fold<int>(
      0,
      (int accumulator, EncodedChar nextEncodedChar) =>
          accumulator + nextEncodedChar.codeUnits!.length,
    );
  }

  /// Calculates the total size in bits of the entire message.
  ///
  /// Returns the total size in bits of the message including headers.
  int get totalSize {
    int size = 0;
    for (Segment segment in segments) {
      size += segment.sizeInBits();
    }
    return size;
  }

  /// Calculates the message size in bits, excluding any user data headers.
  ///
  /// Returns the message size in bits without headers.
  int get messageSize {
    int size = 0;

    for (var segment in segments) {
      size += segment.messageSizeInBits();
    }

    return size;
  }

  /// Gets the number of segments in the message.
  int get segmentsCount => segments.length;

  /// Retrieves a list of characters that are not GSM-7 encoded.
  ///
  /// Returns a list of non-GSM7 characters.
  List<String?> getNonGsmCharacters() {
    return encodedChars
        .where((encodedChar) => !(encodedChar.isGSM7 ?? false))
        .map((encodedChar) => encodedChar.raw)
        .toList();
  }

  /// Detects the line break style used in the message.
  ///
  /// [message] : The message content.
  ///
  /// Returns the line break style used (LF, CRLF, LF+CRLF, or null).
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

  /// Checks for any warnings in the message content.
  ///
  /// [lineBreakStyle] : The line break style detected in the message.
  ///
  /// Returns a list of warnings detected.
  List<String> _checkForWarnings(LineBreakStyle? lineBreakStyle) {
    List<String> warnings = [];

    if (lineBreakStyle != null) {
      warnings.add(
        'The message has line breaks; the web page utility only supports LF style. If you insert a CRLF, it will be converted to LF.',
      );
    }

    return warnings;
  }

  /// Checks if the message contains any UCS-2 characters.
  ///
  /// [graphemes] : List of graphemes in the message.
  ///
  /// Returns true if any character requires UCS-2 encoding, otherwise false.
  bool _hasAnyUCSCharacters(List<String> graphemes) {
    bool result = false;

    for (String grapheme in graphemes) {
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
