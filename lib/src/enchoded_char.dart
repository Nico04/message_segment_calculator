// Assuming unicodeToGsm is a global variable correctly defined elsewhere:
// Map that links Unicode code points to their GSM-7 encoding equivalents.
// Map<int, List<int>> unicodeToGsm;

import '../message_segment_calculator.dart'; // Importing a custom module for message segment calculations.

class EncodedChar {
  // Raw character (grapheme) as passed in the constructor.
  String? raw;

  // List of 8-bit numbers representing the encoded character.
  List<int>? codeUnits;

  // True if the character is a GSM7 one.
  bool? isGSM7;

  // Indicates which encoding to use for this character ('GSM-7' or 'UCS-2').
  String? encoding;

  // Constructor that takes a character and its intended encoding.
  EncodedChar(String char, this.encoding) : raw = char {
    // Determine if the character belongs to the GSM7 set using a predefined map.
    isGSM7 = char.isNotEmpty &&
        char.length == 1 &&
        unicodeToGsm.containsKey(char.codeUnitAt(0));

    // Assign the code units based on whether the character is GSM7 or not.
    if (isGSM7 ?? false) {
      // For GSM-7, fetch the corresponding code units from the map.
      codeUnits = List<int>.from(unicodeToGsm[char.codeUnitAt(
          0)]!); // Using ! because we're sure the value is not null here.
    } else {
      // For non-GSM characters, encode each character as its Unicode scalar values.
      codeUnits = char.runes
          .map((rune) => rune)
          .toList(); // Convert each Unicode scalar value to an integer.
    }
  }

  // Returns the size of a single code unit in bits, based on the encoding used.
  int codeUnitSizeInBits() {
    return encoding == 'GSM-7'
        ? 7 // GSM-7 encoding uses 7 bits per code unit.
        : 16; // UCS-2 encoding uses 16 bits per code unit by definition.
  }

  // Calculates the total size in bits of the encoded character.
  int sizeInBits() {
    if (encoding == 'UCS-2' && (isGSM7 ?? false)) {
      // When using UCS-2 for GSM characters, each character uses 16 bits.
      return codeUnits!.length * 16;
    }
    // Compute the total size by summing the sizes of each code unit.
    // If the character is GSM7, each unit is 7 bits; otherwise, it's 16 bits.
    return codeUnits?.fold(
            0, (int? sum, int unit) => sum! + ((isGSM7 ?? false) ? 7 : 16)) ??
        16; // Default to 16 bits if codeUnits is null.
  }
}
