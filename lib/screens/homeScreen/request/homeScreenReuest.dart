
class HomeScreenRequest {
  final String collection;
  final double version;

  HomeScreenRequest({required this.collection, required this.version});

  Map<String, String> toQueryParams() {
    return {
      'collection': collection,
      'version': version.toString(),
    };
  }
}
