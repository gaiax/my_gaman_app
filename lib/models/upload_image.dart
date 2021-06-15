import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;

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

    if (pickedFile != null) {
      return pickedFile.path;
    }
  }

  static Future<String> uploadFile(imagePath, userId) async {
    File file = File(imagePath);
    await storage.ref('user/'+userId+'/'+userId).putFile(file);

    return await storage.ref('user/'+userId+'/'+userId).getDownloadURL();
  }

  static Future<String> uploadAmazonImg(imagePath, userId, date) async {
    final response = await http.get(Uri.parse(imagePath));
    await storage.ref('user/'+userId+'/'+date).putData(response.bodyBytes);

    return await storage.ref('user/'+userId+'/'+date).getDownloadURL();
  }

  static Future<String> uploadWantImg(imagePath, userId, date) async {
    File file = File(imagePath);
    await storage.ref('user/'+userId+'/'+date).putFile(file);

    return await storage.ref('user/'+userId+'/'+date).getDownloadURL();
  }
}
