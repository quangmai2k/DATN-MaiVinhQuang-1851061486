class CareUser{
  int careUser;
  String ? userCode;
  String ? fullName;
  int countTrainee;
  CareUser({
    required this.careUser,
    required this.userCode,
    required this.fullName,
    required this.countTrainee,
  });

  factory CareUser.fromJson(Map<dynamic,dynamic> json){
    return CareUser(
      careUser: json["nhanvientuyendung"]["careUser"] ?? 0,
      userCode: json["nhanvientuyendung"]["userCode"] ?? "nodata",
      fullName: json["nhanvientuyendung"]["fullName"] ?? "nodata",
      countTrainee: 0,
    );
  }
}
