class ConnectionResponse {
  int? statusCode;
  String? message;
  bool? data;
  String? errorData;
  int? timestamp;

  ConnectionResponse({this.statusCode, this.message, this.data, this.errorData, this.timestamp});

  ConnectionResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];

    if (json['data'] != null) {
      if (json['data'] is bool) {
        data = json['data'];
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
      data['data'] = this.data;
    } else if (this.errorData != null) {
      data['data'] = this.errorData;
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}