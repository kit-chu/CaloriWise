class validateTokenResponse {
  int? statusCode;
  String? errorCode;
  String? message;
  Data? data;
  int? timestamp;

  validateTokenResponse({
    this.statusCode,
    this.errorCode,
    this.message,
    this.data,
    this.timestamp
  });

  validateTokenResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    errorCode = json['errorCode'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['statusCode'] = statusCode;
    data['errorCode'] = errorCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['timestamp'] = timestamp;
    return data;
  }
}

class Data {
  int? status;              // เพิ่ม: 1-10 status code
  bool? valid;
  String? userId;
  String? email;
  String? accessToken;      // เพิ่ม: token ใหม่หรือเดิม
  bool? tokenRefreshed;     // เพิ่ม: บอกว่า token ถูก refresh หรือไม่
  String? message;          // เพิ่ม: error message
  String? lastUpdated;      // เพิ่ม: เวลาอัปเดตล่าสุด

  Data({
    this.status,
    this.valid,
    this.userId,
    this.email,
    this.accessToken,
    this.tokenRefreshed,
    this.message,
    this.lastUpdated
  });

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    valid = json['valid'];
    userId = json['userId'];
    email = json['email'];
    accessToken = json['accessToken'];
    tokenRefreshed = json['tokenRefreshed'];
    message = json['message'];
    lastUpdated = json['lastUpdated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['valid'] = valid;
    data['userId'] = userId;
    data['email'] = email;
    data['accessToken'] = accessToken;
    data['tokenRefreshed'] = tokenRefreshed;
    data['message'] = message;
    data['lastUpdated'] = lastUpdated;
    return data;
  }
}