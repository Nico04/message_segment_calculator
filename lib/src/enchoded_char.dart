// ignore_for_file: public_member_api_docs, sort_constructors_first
// import '../message_segment_calculator.dart';

// // Updated EncodedChar class
// class EncodedChar {
//   String? raw; // Raw character (grapheme)
//   List<int>? codeUnits; // Encoded representation of the character
//   bool? isGSM7; // True if character is GSM7, false otherwise
//   String? encoding; // Encoding type, either 'GSM-7' or 'UCS-2'

//   EncodedChar(String char, this.encoding) : raw = char {
//     // Determine if the character is GSM7
//     isGSM7 = char.isNotEmpty &&
//         char.length == 1 &&
//         unicodeToGsm.containsKey(char.codeUnitAt(0));

//     // If any character is not GSM7, mark the entire encoding as UCS-2
//     if (!(isGSM7 ?? false)) {
//       encoding = 'UCS-2';
//     }

//     // Assign code units based on encoding
//     if (encoding == 'GSM-7' && (isGSM7 ?? false)) {
//       // For GSM-7 characters, use the mapped code units
//       codeUnits = List<int>.from(unicodeToGsm[char.codeUnitAt(0)]!);
//     } else {
//       // For UCS-2 encoding or non-GSM-7 characters
//       codeUnits = char.runes.map((rune) => rune).toList();
//     }
//   }

//   // Returns the size of a single code unit in bits
//   int codeUnitSizeInBits() {
//     return encoding == 'GSM-7' ? 7 : 16; // 7 bits for GSM-7, 16 bits for UCS-2
//   }

//   // Calculates the total size in bits of the encoded character
//   int sizeInBits() {
//     return codeUnits!.length * codeUnitSizeInBits();
//   }
// }

import 'package:message_segment_calculator/message_segment_calculator.dart';
import 'package:message_segment_calculator/src/utils/on_string.dart';

class EncodedChar {
  String? raw;
  List<int>? codeUnits;
  bool? isGSM7;
  String? encoding;
  EncodedChar(String? char, String encodingName) {
    raw = char;
    encoding = encodingName;
    isGSM7 = ((char.notNullNorEmpty) &&
        (char?.length == 1) &&
        unicodeToGsm.containsKey(char?.codeUnitAt(0)));
    if (isGSM7 ?? false) {
      codeUnits = unicodeToGsm[char?.codeUnitAt(0)];
    } else {
      codeUnits = [];
      for (var i = 0; i < char!.length; i++) {
        codeUnits?.add(char.codeUnitAt(i));
      }
    }
  }

  int codeUnitSizeInBits() {
    return encoding == 'gsm7' ? 7 : 8;
  }

  int sizeInBits() {
    if (encoding == 'ucs2' && (isGSM7 ?? false)) {
      return 16;
    }
    final bitsPerUnits = encoding == 'gsm7' ? 7 : 16;
    return bitsPerUnits * codeUnits!.length;
  }
}
