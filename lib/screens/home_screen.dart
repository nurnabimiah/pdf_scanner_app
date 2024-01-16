import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;
import '../controller/doc_pdf_controller.dart';
import 'pdf_viewer_page.dart';

/*class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  @override
  void initState() {
    getPDFFiles();
    super.initState();
  }

  final picker = ImagePicker();
  pw.Document pdf = pw.Document();

  List<File> images = [];

  List<File> pdfFiles = [];

  Future<void> createandSavePDF() async {
    try {
      createPDF();
      var time = DateTime.now().millisecondsSinceEpoch;
      //Use for external storage directory
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/$time.pdf');
      await file.writeAsBytes(await pdf.save());

      if (kDebugMode) {
        print('PDF Path: ${file.path}');
      }
      pdf = pw.Document();
      images = [];
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
            setState(() {
              pdfFiles.add(entity);
            });
          }
        }
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
      setState(() {
        images.addAll(pickedFiles.map((file) {
          return File(file.path);
        }));
      });
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
        setState(() {
          pdfFiles.remove(file);
        });
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
      context: context,
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



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(

        appBar: AppBar(
          title: const Text("Document Scanner"),
          elevation: 0,
          actions: [
            TextButton(
                onPressed: images.isEmpty
                    ? () {} : () async {
                        await createandSavePDF();
                        await getPDFFiles();
                        setState(() {});
                      },
                child: const Text(
                  "Create PDF",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ))
          ],
          bottom: TabBar(
            tabs: [
              Text('Doc pdf Scanner'),
              Text('Id card Scanner'),
              Text('Business Card Scanner'),
            ],
          ),
        ),


        body: TabBarView(
          children: [
            // Index 0
            Container(
              color: Colors.grey,
              child: Stack(
                children: [
                  images.isNotEmpty ? ListView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) =>GestureDetector(
                            onTap: () async {
                              // Get the selected image index
                              int selectedIndex = index;

                              // Crop the selected image
                              CroppedFile? croppedFile = await ImageCropper().cropImage(
                                sourcePath: images[selectedIndex].path,
                                aspectRatioPresets: [
                                  CropAspectRatioPreset.square,
                                  CropAspectRatioPreset.ratio3x2,
                                  CropAspectRatioPreset.original,
                                  CropAspectRatioPreset.ratio4x3,
                                  CropAspectRatioPreset.ratio16x9
                                ],
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: 'Cropper',
                                    toolbarColor: Colors.deepOrange,
                                    toolbarWidgetColor: Colors.white,
                                    initAspectRatio: CropAspectRatioPreset.original,
                                    lockAspectRatio: false,
                                  ),
                                  IOSUiSettings(
                                    title: 'Cropper',
                                  ),
                                  WebUiSettings(
                                    context: context,
                                  ),
                                ],
                              );

                              // Check if the image was cropped successfully
                              if (croppedFile != null) {
                                // Update the UI with the cropped image
                                setState(() {
                                  images[selectedIndex] = File(croppedFile.path);
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.all(8),
                              child: Image.file(
                                images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),



                        )
                      : pdfFiles.isEmpty ? Center(
                              child: Text("No Pdf File Here", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),)
                      : ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (BuildContext context, index) => SizedBox(height: 0),
                              itemCount: pdfFiles.length,

                              itemBuilder: (BuildContext context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    child: ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.red.shade100,
                                        ),
                                        child: Image.asset(
                                          "images/pdf.png",
                                          height: 40,
                                          width: 40,
                                        ),
                                      ),
                                      title: Text(pdfFiles[index].path.split('/').last,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Size: ${formatFileSize(pdfFiles[index].lengthSync())}',
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          deletePDFFile(pdfFiles[index]);
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PDFViewerPage(
                                              pdfPath: pdfFiles[index].path,
                                            ),
                                          ),
                                        );
                                      },
                                      onLongPress: () {},
                                    ),
                                  ),
                                );
                              },
                            ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {


                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (builder) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.300,
                                child: Container(
                                    decoration: new BoxDecoration(
                                        color: Colors.white70.withOpacity(1),
                                        borderRadius: new BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(40.0),
                                            topRight:
                                                const Radius.circular(40.0))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Text('Upload Files'),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'images/camera.png',
                                                  height: 65,
                                                  width: 70,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text('Take a Photo')
                                              ],
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),

                                            /// ...import files
                                            GestureDetector(
                                              onTap: () {},
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'images/import_files.png',
                                                    height: 65,
                                                    width: 70,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text('Import Files'),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),

                                            ///......Gallery...............................

                                            GestureDetector(
                                              onTap: () {
                                                getImageFromGallery();
                                                Navigator.pop(context);
                                              },
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'images/gallery.png',
                                                    height: 65,
                                                    width: 70,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text('Gallery')
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),

                                        // cross....
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Image.asset(
                                            'images/cancel.png',
                                            height: 65,
                                          ),
                                        )
                                      ],
                                    )),
                              );
                            });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Index 1
            Container(
              color: Colors.blue,
              child: Center(
                child: Text('Id card Scanner Content'),
              ),
            ),

            // Index 2
            Container(
              color: Colors.white,
              child: Center(
                child: Text('Business Card Scanner Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }




}*/







class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DocPdfController docPdfController = Get.put(DocPdfController());



  @override
  void initState() {
    docPdfController.getPDFFiles();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
      length: 3,
      child: Scaffold(

        appBar: AppBar(
          title: const Text("Document Scanner"),
          elevation: 0,
          actions: [
            TextButton(
                onPressed: docPdfController.images.isEmpty
                    ? () {} : () async {
                  await docPdfController.createandSavePDF();
                  await docPdfController.getPDFFiles();
                  setState(() {});
                },
                child: const Text(
                  "Create PDF",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ))
          ],
          bottom: TabBar(
            tabs: [
              Text('Doc pdf Scanner'),
              Text('Id card Scanner'),
              Text('Business Card Scanner'),
            ],
          ),
        ),


        body: TabBarView(
          children: [
            // Index 0
            Container(
              color: Colors.grey,
              child: Stack(
                children: [
                  docPdfController.images.isNotEmpty ? ListView.builder(
                    itemCount: docPdfController.images.length,
                    itemBuilder: (context, index) =>GestureDetector(
                      onTap: () async {
                        // Get the selected image index
                        int selectedIndex = index;

                        // Crop the selected image
                        CroppedFile? croppedFile = await ImageCropper().cropImage(
                          sourcePath: docPdfController.images[selectedIndex].path,
                          aspectRatioPresets: [
                            CropAspectRatioPreset.square,
                            CropAspectRatioPreset.ratio3x2,
                            CropAspectRatioPreset.original,
                            CropAspectRatioPreset.ratio4x3,
                            CropAspectRatioPreset.ratio16x9
                          ],
                          uiSettings: [
                            AndroidUiSettings(
                              toolbarTitle: 'Cropper',
                              toolbarColor: Colors.deepOrange,
                              toolbarWidgetColor: Colors.white,
                              initAspectRatio: CropAspectRatioPreset.original,
                              lockAspectRatio: false,
                            ),
                            IOSUiSettings(
                              title: 'Cropper',
                            ),
                            WebUiSettings(
                              context: context,
                            ),
                          ],
                        );

                        // Check if the image was cropped successfully
                        if (croppedFile != null) {
                          // Update the UI with the cropped image
                          setState(() {
                            docPdfController.images[selectedIndex] = File(croppedFile.path);
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(8),
                        child: Image.file(
                          docPdfController.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),



                  )
                      : docPdfController.pdfFiles.isEmpty ? Center(
                    child: Text("No Pdf File Here", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),)
                      : ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, index) => SizedBox(height: 0),
                    itemCount: docPdfController.pdfFiles.length,

                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.shade100,
                              ),
                              child: Image.asset(
                                "images/pdf.png",
                                height: 40,
                                width: 40,
                              ),
                            ),
                            title: Text(docPdfController.pdfFiles[index].path.split('/').last,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Size: ${docPdfController.formatFileSize(docPdfController.pdfFiles[index].lengthSync())}',
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                docPdfController. deletePDFFile(docPdfController.pdfFiles[index]);
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerPage(
                                    pdfPath: docPdfController.pdfFiles[index].path,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {},
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {


                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (builder) {
                              return Container(
                                height:
                                MediaQuery.of(context).size.height * 0.300,
                                child: Container(
                                    decoration: new BoxDecoration(
                                        color: Colors.white70.withOpacity(1),
                                        borderRadius: new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(40.0),
                                            topRight:
                                            const Radius.circular(40.0))),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Text('Upload Files'),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'images/camera.png',
                                                  height: 65,
                                                  width: 70,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text('Take a Photo')
                                              ],
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),

                                            /// ...import files
                                            GestureDetector(
                                              onTap: () {},
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'images/import_files.png',
                                                    height: 65,
                                                    width: 70,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text('Import Files'),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),

                                            ///......Gallery...............................

                                            GestureDetector(
                                              onTap: () {
                                                docPdfController.getImageFromGallery();
                                                Navigator.pop(context);
                                              },
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'images/gallery.png',
                                                    height: 65,
                                                    width: 70,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text('Gallery')
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),

                                        // cross....
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Image.asset(
                                            'images/cancel.png',
                                            height: 65,
                                          ),
                                        )
                                      ],
                                    )),
                              );
                            });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Index 1
            Container(
              color: Colors.blue,
              child: Center(
                child: Text('Id card Scanner Content'),
              ),
            ),

            // Index 2
            Container(
              color: Colors.white,
              child: Center(
                child: Text('Business Card Scanner Content'),
              ),
            ),
          ],
        ),
      ),
    ));
  }




}

