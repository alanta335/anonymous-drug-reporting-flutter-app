class basic_data {
  String? UID;
  String? message;
  //var loc[];
  basic_data.fromJson(Map<String, dynamic> inp) {
    this.UID = inp['UID'];
    this.message = inp['message'];
  }
  Map<String, dynamic> toJson() => {
        'UID': UID,
        'message': message,
      };
}

class json_loc {
  double? lat;
  double? long;
  double? rad;
  json_loc.fromJson(Map<String, dynamic> inp) {
    this.lat = inp['lat'];
    this.long = inp['long'];
    this.rad = inp['radius'];
  }
}
