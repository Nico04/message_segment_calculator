import 'enchoded_char.dart';
import 'user_data_header.dart'; // Importing the UserDataHeader class.

/// Segment Class
/// A wrapper around List to represent one segment and add some helper functions
class Segment {
  // Explicitly typing _elements as List<dynamic> for better type safety and clarity.
  final List<dynamic> _elements = [];

  // Boolean to indicate if Twilio reserved bits are used.
  bool hasTwilioReservedBits;

  // Boolean to indicate if a user data header is present in the segment.
  bool hasUserDataHeader;

  // Constructor with optional parameter to initialize with user data headers.
  Segment({bool withUserDataHeader = false})
      : hasTwilioReservedBits = withUserDataHeader,
        hasUserDataHeader = withUserDataHeader {
    // If initialized with user data header, add 6 user data header objects to _elements.
    if (withUserDataHeader) {
      for (int i = 0; i < 6; i++) {
        _elements.add(UserDataHeader());
      }
    }
  }

  // Getter to provide access to _elements as an unmodifiable list for safety.
  List<dynamic> get elements => List.unmodifiable(_elements);

  // Computes the total size in bits of the segment, including user data headers if present.
  int sizeInBits() {
    return _elements.fold(
        0,
        (int total, dynamic el) =>
            total +
            (el is EncodedChar
                ? el.sizeInBits()
                : (el as UserDataHeader).sizeInBits()));
  }

  // Computes the size in bits of the message content only, excluding user data headers.
  int messageSizeInBits() => _elements
      .whereType<EncodedChar>()
      .fold(0, (int total, EncodedChar el) => total + el.sizeInBits());

  // Calculates the remaining free space in bits within this segment.
  int freeSizeInBits() {
    const int maxBitsInSegment =
        1120; // Maximum size of an SMS is 140 octets -> 140 * 8 bits = 1120 bits
    return maxBitsInSegment - sizeInBits();
  }

  // Adds headers if they are not already present and manages overflow of characters.
  List<EncodedChar> addHeader() {
    if (hasUserDataHeader) {
      return []; // Return an empty list if headers are already present.
    }
    List<EncodedChar> leftOverChar = [];
    hasTwilioReservedBits =
        true; // Indicate that Twilio reserved bits are used.
    hasUserDataHeader = true; // Indicate that a user data header is now added.
    for (int i = 0; i < 6; i++) {
      // Add 6 user data headers at the start of the segment.
      _elements.insert(0, UserDataHeader());
    }
    // Remove elements until there is enough free space in the segment.
    while (freeSizeInBits() < 0 && _elements.isNotEmpty) {
      var removed = _elements.removeLast();
      if (removed is EncodedChar) {
        leftOverChar.insert(
            0, removed); // Add removed encoded chars to the leftover list.
      }
    }
    return leftOverChar; // Return any leftover characters that could not fit after adding headers.
  }

  // Adds an element (either EncodedChar or UserDataHeader) to the segment.
  void add(dynamic element) {
    _elements.add(element);
  }

  // Removes and returns the last element from the segment.
  dynamic removeLast() {
    return _elements.removeLast();
  }
}
