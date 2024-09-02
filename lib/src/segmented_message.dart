import 'package:characters/characters.dart'; // Importing a package to handle Unicode graphemes more efficiently.

import '../message_segment_calculator.dart'; // Import utility for message segment calculations.
import 'enchoded_char.dart';
// Import custom class for handling encoded characters.
import 'segments.dart'; // Import data structure for SMS segments.

enum SmsEncoding { gsm7, ucs2, auto } // Define supported SMS encodings.

enum LineBreakStyle { lf, crlf, lfCrlf, none } // Define types of line breaks.

class SegmentedMessage {
  SmsEncoding? encoding; // The encoding used for the SMS.
  List<Segment> segments = []; // List to store message segments.
  List<String> characters = []; // List of characters in the message.
  SmsEncoding? encodingName; // The name of the encoding used.
  int numberOfUnicodeScalars = 0; // Count of Unicode scalar values.
  int numberOfCharacters = 0; // Count of characters in the message.
  List<EncodedChar> encodedChars = []; // List of encoded characters.
  LineBreakStyle?
      lineBreakStyle; // The style of line breaks used in the message.
  List<String> warnings =
      []; // List to store any warnings generated during processing.

  // Constructor that takes a message string and optionally the encoding and whether to use smart encoding.
  SegmentedMessage(String message,
      [SmsEncoding encoding = SmsEncoding.auto, bool smartEncoding = false]) {
    this.encoding = encoding;

    // Apply smart encoding if enabled, replacing characters based on a predefined map.
    if (smartEncoding) {
      message = message
          .split('')
          .map<String>((char) => smartEncodingMap[char] ?? char)
          .join('');
    }
    // Convert message to a list of graphemes (characters as seen by the user).
    characters = Characters(message).toList();
    // Count the number of Unicode scalars in the message.
    numberOfUnicodeScalars = message.runes.length;

    // Determine encoding based on the content of the message or use the specified encoding.
    if (this.encoding == SmsEncoding.auto) {
      encodingName = _hasAnyUCSCharacters(characters)
          ? SmsEncoding.ucs2
          : SmsEncoding.gsm7;
    } else {
      if (encoding == SmsEncoding.gsm7 && _hasAnyUCSCharacters(characters)) {
        throw Exception(
            'The string provided is incompatible with GSM-7 encoding');
      }
      encodingName = this.encoding;
    }

    // Encode all characters based on the determined encoding.
    encodedChars = _encodeChars(characters);
    // Count characters based on encoding.
    numberOfCharacters = encodingName == SmsEncoding.ucs2
        ? characters.length
        : _countCodeUnits(encodedChars);
    // Build segments for the encoded message.
    segments = _buildSegments(encodedChars);

    // Detect the line break style used in the message.
    lineBreakStyle = _detectLineBreakStyle(message);
    // Check and compile any applicable warnings.
    warnings = _checkForWarnings();
  }

  // Determine if any characters require UCS-2 encoding.
  bool _hasAnyUCSCharacters(List<String> graphemes) {
    return graphemes.any((grapheme) =>
        grapheme.length >= 2 ||
        (grapheme.length == 1 &&
            !unicodeToGsm.containsKey(grapheme.codeUnitAt(0))));
  }

  // Construct SMS segments from a list of encoded characters.
  List<Segment> _buildSegments(List<EncodedChar> encodedChars) {
    List<Segment> segments = [];
    segments.add(Segment());

    Segment currentSegment = segments.first;
    for (EncodedChar encodedChar in encodedChars) {
      if (currentSegment.freeSizeInBits() < encodedChar.sizeInBits()) {
        segments.add(Segment(withUserDataHeader: true));
        currentSegment = segments.last;
        Segment previousSegment = segments[segments.length - 2];

        if (!previousSegment.hasUserDataHeader) {
          List<EncodedChar> removedChars = previousSegment.addHeader();
          for (var char in removedChars) {
            currentSegment.add(char);
          }
        }
      }
      currentSegment.add(encodedChar);
    }
    return segments;
  }

  // Encode graphemes to EncodedChars based on their required encoding.
  List<EncodedChar> _encodeChars(List<String> graphemes) {
    return graphemes
        .map<EncodedChar>(
            (grapheme) => EncodedChar(grapheme, encodingName?.name ?? ""))
        .toList();
  }

  // Count the total number of code units in all encoded characters.
  int _countCodeUnits(List<EncodedChar> encodedChars) {
    return encodedChars.fold(
        0,
        (acumulator, nextEncodedChar) =>
            acumulator + nextEncodedChar.codeUnits!.length);
  }

  // Calculate the total size of the message in bits.
  int get totalSize =>
      segments.fold(0, (total, segment) => total + segment.sizeInBits());

  // Calculate the total message size in bits without headers.
  int get messageSize =>
      segments.fold(0, (total, segment) => total + segment.messageSizeInBits());

  // Get the number of segments needed for the message.
  int get segmentsCount => segments.length;

  // List non-GSM characters in the message.
  List<String?> getNonGsmCharacters() {
    return encodedChars
        .where((encodedChar) => !(encodedChar.isGSM7 ?? false))
        .map((encodedChar) => encodedChar.raw)
        .toList();
  }

  // Detect line break style within the message.
  LineBreakStyle? _detectLineBreakStyle(String message) {
    bool hasWindowsStyle = message.contains('\r\n');
    bool hasUnixStyle = message.contains('\n');
    bool mixedStyle = hasWindowsStyle && hasUnixStyle;

    if (!hasWindowsStyle && !hasUnixStyle) return LineBreakStyle.none;
    if (mixedStyle) return LineBreakStyle.lfCrlf;
    return hasUnixStyle ? LineBreakStyle.lf : LineBreakStyle.crlf;
  }

  // Generate warnings based on line break style and encoding.
  List<String> _checkForWarnings() {
    List<String> warnings = [];
    if (lineBreakStyle != null && lineBreakStyle != LineBreakStyle.none) {
      warnings.add(
          'The message has line breaks, the web page utility only supports LF style. If you insert a CRLF it will be converted to LF.');
    }
    return warnings;
  }
}
