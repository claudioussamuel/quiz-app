abstract class SelectImageState {
  final bool isLoading;
  final String? url;

  const SelectImageState({required this.isLoading, this.url});
}

class SelectImageStateInit extends SelectImageState {
  const SelectImageStateInit({required super.isLoading, super.url});
}

class SelectImageStateUploading extends SelectImageState {
  const SelectImageStateUploading({required super.isLoading, super.url});
}

class SelectImageStateUploaded extends SelectImageState {
  const SelectImageStateUploaded({required super.isLoading, super.url});
}

class SelectImageStateError extends SelectImageState {
  const SelectImageStateError({required super.isLoading, super.url});
}
