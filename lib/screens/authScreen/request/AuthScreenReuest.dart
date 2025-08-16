
class AuthScreenRequest {
  final String collection;
  final double version;

  AuthScreenRequest({required this.collection, required this.version});

  Map<String, String> toQueryParams() {
    return {
      'collection': collection,
      'version': version.toString(),
    };
  }
}
