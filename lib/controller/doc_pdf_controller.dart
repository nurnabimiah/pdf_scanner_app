



import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;
import 'package:path_provider/path_provider.dart';

class DocPdfController extends GetxController {
  final picker = ImagePicker();
  final RxList<File> images = <File>[].obs;
  final RxList<File> pdfFiles = <File>[].obs;
  final pw.Document pdf = pw.Document();

  Future<void> createandSavePDF() async {
    try {
      createPDF();
      var time = DateTime.now().millisecondsSinceEpoch;
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/$time.pdf');
      await file.writeAsBytes(await pdf.save());

      if (kDebugMode) {
        print('PDF Path: ${file.path}');
      }
      pdfFiles.clear();
      pdfFiles.add(file);
      pdfFiles.refresh();
     // pdf.clear();
      images.clear();
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
  }

  Future<void> getPDFFiles() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final List<FileSystemEntity> entities =
        directory.listSync(recursive: true);
        pdfFiles.clear();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.pdf')) {
            pdfFiles.add(entity);
          }
        }
        pdfFiles.refresh();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> getImageFromGallery() async {
    List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      images.addAll(pickedFiles.map((file) => File(file.path)));
      images.refresh();
    } else {
      if (kDebugMode) {
        print('No image selected');
      }
    }
  }

  void createPDF() {
    for (var img in images) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
        pageFormat: pw.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ));
    }
    if (kDebugMode) {
      print("Create PDF");
    }
  }

  String formatFileSize(int fileSize) {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  void showPrintedMessage(BuildContext context, String title, String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(msg),
              ],
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> deletePDFFile(File file) async {
    try {
      bool? confirmDelete = await showDeleteConfirmationDialog(file.path);

      if (confirmDelete!) {
        await file.delete();
        pdfFiles.remove(file);
        pdfFiles.refresh();
        print('PDF file deleted: ${file.path}');
      } else {
        print('User canceled deletion.');
      }
    } catch (e) {
      print('Error deleting PDF file: $e');
    }
  }

  Future<bool?> showDeleteConfirmationDialog(String filePath) async {
    return await showDialog<bool>(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the file:?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
