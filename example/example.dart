import '../lib/src/sms_segment_calculator.dart';

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
