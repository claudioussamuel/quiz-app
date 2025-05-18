class CloudStorageException implements Exception {
  const CloudStorageException();
}

// create
class CouldNotCreateUserException extends CloudStorageException {}

//read
class CouldNotGetAllUsersException extends CloudStorageException {}

//update
class CouldNotUpdateUserException extends CloudStorageException {}

//delete
class CouldNotDeleteUserException extends CloudStorageException {}
