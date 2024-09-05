import 'package:flutter/material.dart';
import 'package:message_segment_calculator/src/segmented_message.dart';

void main() {
  // Define a sample text for segmentation.
//   String sampleText =
//       '''"You can use a placeholder as shown in the following message and it will replace it automatically with an appropriate value.
// It also supports randomizing message using spintax.
// '[Hi|Hello|Hey] {first name}, How are you?' In the above example, the system will replace {first name} with data from the Name column.

// // Please clear this message to draft a new message''';

//   try {
//     // Initialize SegmentedMessage with the provided text.
//     SegmentedMessage segmentedMessage = SegmentedMessage(sampleText);

//     // Output various properties of the segmented message to understand its structure.
//     print(
//         "Total Size in Bits: ${segmentedMessage.totalSize}"); // Prints the total size of the message in bits.
//     print(
//         "Message Size in Bits: ${segmentedMessage.messageSize}"); // Prints the message size in bits, excluding headers.
//     print(
//         "Segments Count: ${segmentedMessage.segmentsCount}"); // Prints the number of segments the message is divided into.
//     print(
//         "Number of Characters: ${segmentedMessage.numberOfCharacters}"); // Prints the total number of characters in the message.
//     print(
//         "Number of Unicode Scalars: ${segmentedMessage.numberOfUnicodeScalars}"); // Prints the number of Unicode scalars in the message.
//   } catch (e) {
//     // Handle any exceptions that might be thrown during the segmentation process.
//     print('An error occurred: $e');
//   }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MessageSegmentCalculatorWidget(),
    );
  }
}

class MessageSegmentCalculatorWidget extends StatefulWidget {
  const MessageSegmentCalculatorWidget({super.key});

  @override
  State<MessageSegmentCalculatorWidget> createState() =>
      _MessageSegmentCalculatorWidgetState();
}

class _MessageSegmentCalculatorWidgetState
    extends State<MessageSegmentCalculatorWidget> {
  final textEditingController = TextEditingController(
      text:
          '''You can use a placeholder as shown in the following message and it will replace it automatically with an appropriate value.
It also supports randomizing message using spintax.
'[Hi|Hello|Hey] {first name}, How are you?' In the above example, the system will replace {first name} `with data from the Name column.
 
// Please clear this message to draft a new message''');
  SegmentedMessage? segmentedMessage;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Segment Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text('Enter text'),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              decoration: const InputDecoration(),
              controller: textEditingController,
              onChanged: (value) {
                setState(() {
                  segmentedMessage = SegmentedMessage(value);
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),

            /// print the results
            /// number of characters
            Text(
                'number of characters : ${segmentedMessage?.numberOfCharacters} '),

            /// number of segments
            Text('number of segments : ${segmentedMessage?.segmentsCount}'),

            /// number of unicode scalars
            Text(
                'number of unicode scalars : ${segmentedMessage?.numberOfUnicodeScalars}'),

            /// message size in bits
            Text('message size in bits : ${segmentedMessage?.messageSize}'),

            /// total size in bits
            Text('total size in bits : ${segmentedMessage?.totalSize}'),
          ],
        ),
      ),
    );
  }
}
