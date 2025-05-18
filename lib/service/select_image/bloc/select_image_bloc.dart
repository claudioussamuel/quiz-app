import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/image_picker/image_picker.dart';
import 'select_image_event.dart';
import 'select_image_state.dart';

class SelectImageBloc extends Bloc<SelectImageEvent, SelectImageState> {
  SelectImageBloc()
      : super(
          const SelectImageStateInit(
            isLoading: false,
            url: "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
          ),
        ) {
    on<SelectImageEventFireStore>((event, emit) {
      emit(
        SelectImageStateUploaded(
          isLoading: false,
          url: event.imageSource,
        ),
      );
    });
    on<SelectImageEventUpload>((event, emit) async {
      try {
        Uint8List img = await pickImage(event.imageSource);
        if (img.isNotEmpty) {
          emit(const SelectImageStateUploading(isLoading: true));
          // Generate unique file name using timestamp
          String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}';

          // Detect image format (you might want to add more sophisticated detection)
          String contentType;
          String extension;

          // Simple check for PNG signature
          if (img.length > 8 &&
              img[0] == 0x89 &&
              img[1] == 0x50 &&
              img[2] == 0x4E &&
              img[3] == 0x47) {
            contentType = 'image/png';
            extension = 'png';
          } else {
            contentType = 'image/jpeg';
            extension = 'jpg';
          }

          fileName = '$fileName.$extension';

          // Get reference to Firebase Storage
          final storageRef =
              FirebaseStorage.instance.ref().child('profile_images/$fileName');

          // Upload image
          final uploadTask = await storageRef.putData(
            img,
            SettableMetadata(contentType: contentType),
          );

          // Get download URL
          final imageUrl = await uploadTask.ref.getDownloadURL();

          emit(SelectImageStateUploaded(isLoading: false, url: imageUrl));
        }
      } catch (e) {
        emit(
          SelectImageStateInit(
            isLoading: false,
            url: "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
          ),
        );
      }
    });
  }
}
