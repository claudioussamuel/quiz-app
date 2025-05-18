import 'package:image_picker/image_picker.dart';

abstract class SelectImageEvent {}

class SelectImageEventInit extends SelectImageEvent {
  SelectImageEventInit();
}

class SelectImageEventUpload extends SelectImageEvent {
  final ImageSource imageSource;

  SelectImageEventUpload({required this.imageSource});
}

class SelectImageEventFireStore extends SelectImageEvent {
  final String imageSource;

  SelectImageEventFireStore({required this.imageSource});
}
