import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

bool _isSharing = false;

Future<void> handleShare(String message) async {
  // Prevent multiple simultaneous share operations
  if (_isSharing) {
    debugPrint('Share operation already in progress, skipping...');
    return;
  }

  try {
    _isSharing = true;

    if (message.startsWith('share:')) {
      final JSONdata = message.substring(6); // Remove 'share:' prefix
      final data = json.decode(JSONdata);

      if (data is Map<String, dynamic>) {
        final text = data['text'] as String?;
        final subject = data['subject'] as String?;
        final imagePath = data['imagePath'] as String?;

        if (imagePath != null) {
          try {
            // Convert base64 to bytes

            debugPrint('handleShare: $message');
            final imageData =
                imagePath.split(',')[1]; // Remove data:image/png;base64,
            final bytes = base64Decode(imageData);

            // Create temporary file
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/share_image.png');
            await file.writeAsBytes(bytes);

            // Use shareFilesWithResult to properly handle the share result
            final result = await Share.shareFilesWithResult(
              [file.path],
              text: text,
              subject: subject,
            );

            // Handle the result
            switch (result.status) {
              case ShareResultStatus.success:
                debugPrint('Share completed successfully');
                break;
              case ShareResultStatus.dismissed:
                debugPrint('Share dismissed by user');
                break;
              case ShareResultStatus.unavailable:
                debugPrint('Share unavailable');
                // Fallback to text-only sharing if image sharing is unavailable
                if (text != null) {
                  await Share.share(text, subject: subject);
                }
                break;
            }
          } catch (e) {
            debugPrint('Error sharing image: $e');
            // Fallback to text-only sharing if image sharing fails
            if (text != null) {
              await Share.share(text, subject: subject);
            }
          }
        } else if (text != null) {
          await Share.share(text, subject: subject);
        }
      }
    }
  } catch (e) {
    debugPrint('Error in handleShare: $e');
  } finally {
    _isSharing = false;
  }
}
