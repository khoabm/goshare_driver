class Failure {
  final String message;

  Failure(this.message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(super.message);
}

class UpdateProfileFailure extends Failure {
  UpdateProfileFailure(super.message);
}
