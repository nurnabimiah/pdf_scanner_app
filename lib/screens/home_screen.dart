import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _images = [];

  Future<void> getImageFromGallery() async {
    List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        // _images = pickedFiles.map((file) => File(file.path)).toList();
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    } else {
      print('No image selected');
    }
  }

  void createPDF() {
    for (var img in _images) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
        pageFormat: pw.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ));
    }
  }

  void savePDF() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/filename.pdf');
      await file.writeAsBytes(await pdf.save());
      showPrintedMessage(context, 'Success', 'Saved to documents');
    } catch (e) {
      showPrintedMessage(context, 'Error', e.toString());
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





  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(

        appBar: AppBar(
          title: Text("Document Scanner"),
          elevation: 0,
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
                  _images.isNotEmpty
                      ? ListView.builder(
                    itemCount: _images.length,
                    itemBuilder: (context, index) => Container(
                      height: 400,
                      width: double.infinity,
                      margin: EdgeInsets.all(8),
                      child: Image.file(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      :
                  ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, index) =>
                        SizedBox(height: 0),
                    itemCount: 3,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding:  EdgeInsets.only(left: 0.0,right: 200,top: 5),
                        child: Container(
                          height: 50,
                          color: Colors.white,
                          child: Center(child: Text("Doc Scanner $index")),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: (){
                        print('item is clicked');

                          showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (builder) {
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.300,
                                  child: Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.white70.withOpacity(1),
                                          borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(40.0),
                                              topRight: const Radius.circular(40.0))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Text('Upload Files'),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
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
                        }
                      ,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: Colors.white,),
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
}





