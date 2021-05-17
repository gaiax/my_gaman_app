import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

PickedFile pickedFile;
firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

Future getImage(bool gallery) async {
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

Future<void> uploadFile(imagePath, userEmail) async {
  File file = File(imagePath);
  await storage.ref('userImages/'+userEmail+'.png').putFile(file);
}
