import 'encoded_char.dart';
import 'user_data_header.dart'; // Importing the UserDataHeader class.

/// Represents a segment of an SMS message.
/// This class wraps around a list to represent one segment and provides helper functions
/// to manage the segment's content, including the handling of encoded characters and user data headers.
class Segment {
  /// Internal list to store the elements (either EncodedChar or UserDataHeader) within the segment.
  final List<dynamic> _elements = [];

  /// Indicates if Twilio reserved bits are being used in this segment.
  bool hasTwilioReservedBits;

  /// Indicates if a user data header is present in the segment.
  bool hasUserDataHeader;

  /// Creates a new instance of [Segment].
  ///
  /// [withUserDataHeader] specifies whether the segment should be initialized with a user data header.
  Segment({bool withUserDataHeader = false})
      : hasTwilioReservedBits = withUserDataHeader,
        hasUserDataHeader = withUserDataHeader {
    /// If initialized with a user data header, add 6 user data header objects to [_elements].
    if (withUserDataHeader) {
      for (int i = 0; i < 6; i++) {
        _elements.add(UserDataHeader());
      }
    }
  }

  /// Provides an unmodifiable view of the elements within the segment.
  ///
  /// Returns a list containing all elements (EncodedChar or UserDataHeader) in this segment.
  List<dynamic> get elements => List.unmodifiable(_elements);

  /// Computes the total size of the segment in bits, including any user data headers.
  ///
  /// Returns the total size in bits of all the elements in the segment.
  int sizeInBits() {
    return _elements.fold(
        0,
        (int total, dynamic el) =>
            total + (el is EncodedChar ? el.sizeInBits() : 0));
  }

  /// Computes the size of the message content in bits, excluding user data headers.
  ///
  /// Returns the size in bits of the message content only.
  int messageSizeInBits() => _elements.whereType<EncodedChar>().fold(
      0,
      (int total, var el) =>
          total + (el is! UserDataHeader ? el.sizeInBits() : 0));

  /// Calculates the remaining free space in bits within this segment.
  ///
  /// Returns the number of free bits available in this segment.
  int freeSizeInBits() {
    const int maxBitsInSegment =
        1120; // Maximum size of an SMS is 140 octets -> 140 * 8 bits = 1120 bits
    return maxBitsInSegment - sizeInBits();
  }

  /// Adds a user data header to the segment if it is not already present.
  /// Manages overflow of characters if the addition of headers causes the segment to exceed its size limit.
  ///
  /// Returns a list of [EncodedChar] that could not fit in the segment after adding the headers.
  List<EncodedChar> addHeader() {
    if (hasUserDataHeader) {
      return []; // Return an empty list if headers are already present.
    }
    List<EncodedChar> leftOverChar = [];
    hasTwilioReservedBits =
        true; // Indicate that Twilio reserved bits are used.
    hasUserDataHeader = false; // Indicate that a user data header is now added.

    // Add 6 user data headers at the start of the segment.
    for (int i = 0; i < 6; i++) {
      _elements.insert(0, UserDataHeader());
    }

    // Remove elements until there is enough free space in the segment.
    while (freeSizeInBits() < 0) {
      leftOverChar.insert(0, removeLast());
    }
    return leftOverChar; // Return any leftover characters that could not fit after adding headers.
  }

  /// Adds an element (either [EncodedChar] or [UserDataHeader]) to the segment.
  ///
  /// [element] is the element to be added to the segment.
  void add(dynamic element) {
    _elements.add(element);
  }

  /// Removes and returns the last element from the segment.
  ///
  /// Returns the last element (EncodedChar or UserDataHeader) removed from the segment.
  dynamic removeLast() {
    return _elements.removeLast();
  }

  @override
  String toString() => 'Segment{hasTwilioReservedBits: $hasTwilioReservedBits, hasUserDataHeader: $hasUserDataHeader, sizeInBits: ${sizeInBits()}, messageSizeInBits: ${messageSizeInBits()}, freeSizeInBits: ${freeSizeInBits()}}';
}
