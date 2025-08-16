class DeviceInfoRequest {
  final String? deviceId;
  final String? platform;
  final String? osVersion;
  final String? deviceModel;

  DeviceInfoRequest({
    this.deviceId,
    this.platform,
    this.osVersion,
    this.deviceModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'platform': platform,
      'os_version': osVersion,
      'device_model': deviceModel,
    };
  }

  factory DeviceInfoRequest.fromJson(Map<String, dynamic> json) {
    return DeviceInfoRequest(
      deviceId: json['device_id'],
      platform: json['platform'],
      osVersion: json['os_version'],
      deviceModel: json['device_model'],
    );
  }
}