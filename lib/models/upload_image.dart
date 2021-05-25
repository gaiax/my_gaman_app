import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadImage {
  static PickedFile pickedFile;
  static firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  static Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    // Let user select photo from gallery
    if(gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,);
    } 
    // Otherwise open camera to get new photo
    else{
      pickedFile = await picker.getImage(
        source: ImageSource.camera,);
    }

    return pickedFile.path;
  }

  static Future<void> uploadFile(imagePath, userId) async {
    File file = File(imagePath);
    await storage.ref('user/'+userId+'/'+userId).putFile(file);
  }
}
