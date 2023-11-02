import 'dart:io';
import 'package:camera_appp/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Camapp extends StatefulWidget {
  const Camapp({super.key});

  @override
  State<Camapp> createState() => _CamappState();
}

File? selectedImage;
late List<Map<String, dynamic>> imageList = [];
List<File> recentimage = [];

class _CamappState extends State<Camapp> {

  @override
  
  Future<void> initializeSelectedImage() async {
    File? image = await selectImageFromCamera(context);
    setState(() {
      selectedImage = image;
    });
    if (selectedImage != null) {
      addImageToDB(selectedImage!.path);
      recentimage.add(selectedImage!);
    }
    fetchImage();
  }

  Future<void> fetchImage() async {
    List<Map<String, dynamic>> listFromDB = await getImagesFromDB();
    setState(() {
      imageList = listFromDB;
    });
  }

  Future<File?> selectImageFromCamera(BuildContext context) async {
    File? image;
    try {
      final pickimage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickimage != null) {
        image = File(pickimage.path);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(
          context, e.toString(), const Color.fromARGB(255, 232, 41, 28));
    }
    return image;
  }

  void showSnackbar(BuildContext context, String content, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(content), backgroundColor: color));
  }

  @override
  
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Center(
              child: Text(
                "Camera Application",
                style: GoogleFonts.poppins(),
              ),
            ),
            bottom: TabBar(
              labelStyle: GoogleFonts.montserrat(
                  fontSize: 17, fontWeight: FontWeight.w500),
              indicatorColor: const Color.fromARGB(255, 255, 255, 255),
              tabs: const [
                Tab(
                  text: 'Recent',
                ),
                Tab(
                  text: 'Gallery',
                ),
              ],
            ),
          ),
          body: TabBarView(children: [
            recentimage.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                               mainAxisSpacing: 10),
                        itemCount: recentimage.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              showselectedImageDialog(
                                  context, recentimage[index]);
                            },
                            child: ClipRRect(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0)),
                                child: Image.file(recentimage[index]),
                              ),
                            ),
                          );
                        }))
                : const Center(child: Text("Take a photo ")),
            Container(
                padding: const EdgeInsets.only(top: 10),
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 10),
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      final imagemap = imageList[index];
                      final imageFile = File(imagemap['imagesrc']);
                      final id = imagemap['id'];
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              showselectedImageDialog(context, imageFile);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(imageFile),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 30,
                            child: CircleAvatar(
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: const Text("Delete Image"),
                                          content: const Text(
                                              "Are you sure you want to Deleted?"),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await deleteImageFromDB(id);
                                                fetchImage();
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop();
                                                // ignore: use_build_context_synchronously
                                                snackbarFunction(
                                                    context,
                                                    "succesfully deleted...",
                                                    Colors.green);
                                              },
                                              child: const Text('Ok'),
                                            )
                                          ]);
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    })),
          ]),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await initializeSelectedImage();
              },
              child: const Icon(Icons.camera_enhance)),
        ));
  }
}

// ignore: non_constant_identifier_names
void showselectedImageDialog(BuildContext context, File ImageFile) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: Image.file(ImageFile),
          ),
        );
      });
}

void snackbarFunction(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(content), backgroundColor: color));
}
   