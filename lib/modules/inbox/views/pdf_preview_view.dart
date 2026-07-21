import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:watibot/core/services/api_service.dart';

class PdfPreviewView extends StatelessWidget {
  const PdfPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final String pdfUrl = Get.arguments as String;
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Document Preview', style: TextStyle(color: Colors.black87, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              // Zoom functionality can be controlled manually if needed, 
              // but SfPdfViewer handles pinch-to-zoom automatically.
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        key: pdfViewerKey,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        headers: ApiService.getMediaHeaders(pdfUrl),
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('PDF Load Failed: ${details.error}');
          debugPrint('PDF Load Failed Description: ${details.description}');
          Get.snackbar(
            'Error Loading PDF',
            'URL: $pdfUrl\nDesc: ${details.description}\nErr: ${details.error}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 10),
          );
        },
      ),
    );
  }
}
