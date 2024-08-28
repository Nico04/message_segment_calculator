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

The SMS Segment Calculator is a Dart package designed to help developers accurately calculate the number of SMS segments required for messages, taking into account both GSM and UCS-2 encoding standards. This is essential for applications that involve SMS messaging, where managing the length and cost of messages is crucial.

## Key Features

- **Accurate SMS Segmentation**: Determines how many segments a given SMS message will require based on its content and the necessary encoding (GSM or UCS-2).
- **Support for Special Characters and Emojis**: Automatically handles texts containing emojis and special characters by switching to UCS-2 encoding when required.
- **Ease of Integration**: Offers simple, straightforward functions that can be easily integrated into any Dart or Flutter project to enhance SMS functionalities.
- **Cost-Effective Messaging**: Helps in effectively managing SMS costs by providing precise segment counts for accurate budgeting and planning.

## Getting Started

To integrate the SMS Segment Calculator into your Dart or Flutter project, follow these steps:

### Installation

Add the SMS Segment Calculator to your project by including it in your `pubspec.yaml` file:

```yaml
dependencies:
  sms_segment_calculator: ^0.1.0


## Usage

import 'package:sms_segment_calculator/sms_segment_calculator.dart';

void main() {
  String message = '''Hi Roberta 
Its Peter with Krown Funding touching base
Its not too late to get funded b4 the weekend 🤑
Reply Yes to Get Funded Today or DND to optout''';
  final segments = SMSegmentCalculator.calculateSegments(message);
  print(
      'Total segments: ${segments.totalSegments}'); // Output should be correct based on encoding
  print('Total characters count: ${segments.characterCount}');
}

