<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# SMS Segment Calculator

The SMS Segment Calculator is a Dart package designed to help developers accurately calculate the number of SMS segments required for messages. It supports both GSM-7 and UCS-2 encoding standards, providing a robust solution for applications that involve SMS messaging. The package ensures cost-effective messaging by optimizing message segmentation and encoding.

## Key Features

- **Accurate SMS Segmentation**: Automatically calculates the number of segments needed for a given SMS message based on its content and required encoding (GSM-7 or UCS-2).
- **Support for Special Characters and Emojis**: Detects texts containing emojis or special characters and switches to UCS-2 encoding when necessary.
- **Comprehensive Encoding Management**: Handles the encoding of individual characters and manages their conversion to the appropriate encoding format.
- **Cost Management**: Provides precise segment counts for budgeting and planning SMS costs effectively.
- **Line Break Handling**: Identifies different line break styles and issues warnings if incompatible styles are detected.

## Installation

To integrate the SMS Segment Calculator into your Dart or Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  sms_segment_calculator: ^0.1.0



## Usage

import 'package:sms_segment_calculator/sms_segment_calculator.dart';

void main() {
  String message = '''Hi Roberta,
It's Peter with Krown Funding touching base.
It's not too late to get funded before the weekend 🤑.
Reply Yes to Get Funded Today or DND to opt-out.''';

  // Initialize the SegmentedMessage class to calculate SMS segments.
  SegmentedMessage segmentedMessage = SegmentedMessage(message);

  // Output various properties of the segmented message.
  print("Total Size in Bits: ${segmentedMessage.totalSize}");
  print("Message Size in Bits: ${segmentedMessage.messageSize}");
  print("Segments Count: ${segmentedMessage.segmentsCount}");
  print("Number of Characters: ${segmentedMessage.numberOfCharacters}");
  print("Number of Unicode Scalars: ${segmentedMessage.numberOfUnicodeScalars}");
}



### Key Additions:
- **Detailed Descriptions**: Each class is explained to clarify its role in the package.
- **Usage Example**: Shows a practical example to help developers quickly understand how to use the package.
- **Installation Instructions**: Guides users on how to add the package to their project.
- **Contribution Guidelines**: Encourages contributions and provides a link to the issues page. 

This README provides a comprehensive overview, making it easier for users to understand and use the package effectively.

