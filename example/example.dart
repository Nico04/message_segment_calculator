import 'dart:developer';

import 'package:message_segment_calculator/src/segmented_message.dart';

void main() {
  // Define a sample text for segmentation.
  String sampleText = 'Hello ';

  try {
    // Initialize SegmentedMessage with the provided text.
    SegmentedMessage segmentedMessage = SegmentedMessage(sampleText);

    // Output various properties of the segmented message to understand its structure.
    log("Total Size in Bits: ${segmentedMessage.totalSize}"); // Prints the total size of the message in bits.
    log("Message Size in Bits: ${segmentedMessage.messageSize}"); // Prints the message size in bits, excluding headers.
    log("Segments Count: ${segmentedMessage.segmentsCount}"); // Prints the number of segments the message is divided into.
    log("Number of Characters: ${segmentedMessage.numberOfCharacters}"); // Prints the total number of characters in the message.
    log("Number of Unicode Scalars: ${segmentedMessage.numberOfUnicodeScalars}"); // Prints the number of Unicode scalars in the message.
  } catch (e) {
    // Handle any exceptions that might be thrown during the segmentation process.
    log('An error occurred: $e');
  }
}
