import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/logo.png');
  if (!file.existsSync()) {
    print('logo.png not found');
    return;
  }

  // Decode the image
  final original = img.decodeImage(file.readAsBytesSync());
  if (original == null) {
    print('Failed to decode image');
    return;
  }

  // Calculate new size (make it a square, adding some padding)
  final size = original.width > original.height ? original.width : original.height;
  // Add some extra padding so it doesn't touch the edges (e.g., 20% padding)
  final paddedSize = (size * 1.5).round();

  // Create a new square image with a white or transparent background
  final paddedImage = img.Image(width: paddedSize, height: paddedSize);
  
  // Fill background with white or a very slight off-white color so it looks good on iOS/Android
  // For transparency on Android adaptive, we might want it transparent or white.
  // Let's use white #FFFFFF
  img.fill(paddedImage, color: img.ColorRgb8(255, 255, 255));

  // Draw the original image in the center
  final dstX = (paddedSize - original.width) ~/ 2;
  final dstY = (paddedSize - original.height) ~/ 2;
  
  img.compositeImage(paddedImage, original, dstX: dstX, dstY: dstY);

  // Save the result
  final resultFile = File('assets/icon_square.png');
  resultFile.writeAsBytesSync(img.encodePng(paddedImage));
  print('Successfully created icon_square.png');
}
