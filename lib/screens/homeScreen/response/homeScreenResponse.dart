




class HomeScreenResponse {
  int? statusCode;
  String? message;
  Data? data;
  String? errorData;
  int? timestamp;

  HomeScreenResponse({this.statusCode, this.message, this.data, this.errorData, this.timestamp});

  HomeScreenResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];

    // ตรวจสอบว่า data เป็น Map หรือ String
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = Data.fromJson(json['data']);
      } else if (json['data'] is String) {
        errorData = json['data'];
      }
    }

    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    } else if (this.errorData != null) {
      data['data'] = this.errorData;
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Data {
  double? version;
  String? screen;
  List<Items>? items;

  Data({this.version, this.screen, this.items});

  Data.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    screen = json['screen'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['screen'] = this.screen;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? table;
  String? th;
  String? en;

  Items({this.table, this.th, this.en});

  Items.fromJson(Map<String, dynamic> json) {
    table = json['table'];
    th = json['th'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['table'] = this.table;
    data['th'] = this.th;
    data['en'] = this.en;
    return data;
  }
}
