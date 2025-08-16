class AuthLoginGoogleResponse {
  int? statusCode;
  Null? errorCode;
  String? message;
  Data? data;
  int? timestamp;

  AuthLoginGoogleResponse(
      {this.statusCode,
        this.errorCode,
        this.message,
        this.data,
        this.timestamp});

  AuthLoginGoogleResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    errorCode = json['errorCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['errorCode'] = this.errorCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Data {
  String? userId;
  String? email;
  String? name;
  String? picture;
  String? token;
  String? refreshToken;

  Data(
      {this.userId,
        this.email,
        this.name,
        this.picture,
        this.token,
        this.refreshToken});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    email = json['email'];
    name = json['name'];
    picture = json['picture'];
    token = json['token'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['email'] = this.email;
    data['name'] = this.name;
    data['picture'] = this.picture;
    data['token'] = this.token;
    data['refreshToken'] = this.refreshToken;
    return data;
  }
}
