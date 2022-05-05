class basic_data {
  String? UID;
  String? message;

  basic_data.fromJson(Map<String, dynamic> inp) {
    this.UID = inp['UID'];
    this.message = inp['message'];
  }
  Map<String, dynamic> toJson() => {
        'UID': UID,
        'message': message,
      };
}
