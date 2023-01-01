// class Donhang {
//   int? id;
//   int? modifiedUser;
//   String? modifiedDate;
//   int? createdUser;
//   String? createdDate;
//   String? orderCode;
//   String? orderName;
//   int? orgId;
//   // Nghiepdoan? nghiepdoan;
//   int? companyId;
//   // Xinghiep? xinghiep;
//   String? workAddress;
//   int? jobId;
//   // Nganhnghe? nganhnghe;
//   int? jobDetailId;
//   // NganhngheCuthe? nganhngheCuthe;
//   String? implementTime;
//   int? genderRequired;
//   int? ageFrom;
//   int? ageTo;
//   int? ttsRequired;
//   int? ttsMaleRequired;
//   int? ttsFemaleRequired;
//   int? ttsCandidates;
//   int? ttsMaleCandidates;
//   int? ttsFemaleCandidates;
//   int? academicId;
//   // Trinhdohocvan? trinhdohocvan;
//   String? skill;
//   String? eyeSight;
//   String? eyeSightGlasses;
//   String? eyeSightSurgery;
//   int? height;
//   int? weight;
//   int? rightHanded;
//   int? leftHanded;
//   int? maritalStatus;
//   int? smoke;
//   int? drinkAlcohol;
//   int? tattoo;
//   int? everSurgery;
//   int? everCesareanSection;
//   String? otherHealthRequired;
//   int? otherHealthRequiredAccept;
//   String? priorityCases;
//   String? restrictionCases;
//   int? recruiMethod;
//   String? recruiContent;
//   int? testFormNumber;
//   String? sendListFormDate;
//   String? estimatedInterviewDate;
//   String? estimatedAdmissionDate;
//   String? estimatedEntryDate;
//   String? firstMonthSubsidy;
//   String? salary;
//   String? insurance;
//   String? livingCost;
//   String? netMoney;
//   int? orderUrgent;
//   String? image;
//   String? description;
//   int? nominateStatus;
//   int? closeNominateUser;
//   // NguoichotTiencu? nguoichotTiencu;
//   String? closeNominateDate;
//   int? orderStatusId;
//   // TrangthaiDonhang? trangthaiDonhang;
//   int? orderBonus;
//   int? aamUser;
//   // NguoichotTiencu? nhanvienXuly;
//   Null? approver;
//   Null? nguoiduyetNhanvienxuly;
//   Null? changeUserDate;
//   int? publishUser;
//   // Nguoixuatban? nguoixuatban;
//   String? publishDate;
//   int? stopProcessing;

//   Donhang(
//       {this.id,
//       this.modifiedUser,
//       this.modifiedDate,
//       this.createdUser,
//       this.createdDate,
//       this.orderCode,
//       this.orderName,
//       this.orgId,
//       // this.nghiepdoan,
//       this.companyId,
//       // this.xinghiep,
//       this.workAddress,
//       this.jobId,
//       // this.nganhnghe,
//       this.jobDetailId,
//       // this.nganhngheCuthe,
//       this.implementTime,
//       this.genderRequired,
//       this.ageFrom,
//       this.ageTo,
//       this.ttsRequired,
//       this.ttsMaleRequired,
//       this.ttsFemaleRequired,
//       this.ttsCandidates,
//       this.ttsMaleCandidates,
//       this.ttsFemaleCandidates,
//       this.academicId,
//       // this.trinhdohocvan,
//       this.skill,
//       this.eyeSight,
//       this.eyeSightGlasses,
//       this.eyeSightSurgery,
//       this.height,
//       this.weight,
//       this.rightHanded,
//       this.leftHanded,
//       this.maritalStatus,
//       this.smoke,
//       this.drinkAlcohol,
//       this.tattoo,
//       this.everSurgery,
//       this.everCesareanSection,
//       this.otherHealthRequired,
//       this.otherHealthRequiredAccept,
//       this.priorityCases,
//       this.restrictionCases,
//       this.recruiMethod,
//       this.recruiContent,
//       this.testFormNumber,
//       this.sendListFormDate,
//       this.estimatedInterviewDate,
//       this.estimatedAdmissionDate,
//       this.estimatedEntryDate,
//       this.firstMonthSubsidy,
//       this.salary,
//       this.insurance,
//       this.livingCost,
//       this.netMoney,
//       this.orderUrgent,
//       this.image,
//       this.description,
//       this.nominateStatus,
//       this.closeNominateUser,
//       // this.nguoichotTiencu,
//       this.closeNominateDate,
//       this.orderStatusId,
//       // this.trangthaiDonhang,
//       this.orderBonus,
//       this.aamUser,
//       // this.nhanvienXuly,
//       this.approver,
//       this.nguoiduyetNhanvienxuly,
//       this.changeUserDate,
//       this.publishUser,
//       // this.nguoixuatban,
//       this.publishDate,
//       this.stopProcessing});

//   Donhang.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     modifiedUser = json['modifiedUser'];
//     modifiedDate = json['modifiedDate'];
//     createdUser = json['createdUser'];
//     createdDate = json['createdDate'];
//     orderCode = json['orderCode'];
//     orderName = json['orderName'];
//     orgId = json['orgId'];
//     // nghiepdoan = json['nghiepdoan'] != null ? new Nghiepdoan.fromJson(json['nghiepdoan']) : null;
//     companyId = json['companyId'];
//     // xinghiep = json['xinghiep'] != null ? new Xinghiep.fromJson(json['xinghiep']) : null;
//     workAddress = json['workAddress'];
//     jobId = json['jobId'];
//     // nganhnghe = json['nganhnghe'] != null ? new Nganhnghe.fromJson(json['nganhnghe']) : null;
//     jobDetailId = json['jobDetailId'];
//     // nganhngheCuthe = json['nganhnghe_cuthe'] != null ? new NganhngheCuthe.fromJson(json['nganhnghe_cuthe']) : null;
//     implementTime = json['implementTime'];
//     genderRequired = json['genderRequired'];
//     ageFrom = json['ageFrom'];
//     ageTo = json['ageTo'];
//     ttsRequired = json['ttsRequired'];
//     ttsMaleRequired = json['ttsMaleRequired'];
//     ttsFemaleRequired = json['ttsFemaleRequired'];
//     ttsCandidates = json['ttsCandidates'];
//     ttsMaleCandidates = json['ttsMaleCandidates'];
//     ttsFemaleCandidates = json['ttsFemaleCandidates'];
//     academicId = json['academicId'];
//     // trinhdohocvan = json['trinhdohocvan'] != null ? new Trinhdohocvan.fromJson(json['trinhdohocvan']) : null;
//     skill = json['skill'];
//     eyeSight = json['eyeSight'];
//     eyeSightGlasses = json['eyeSightGlasses'];
//     eyeSightSurgery = json['eyeSightSurgery'];
//     height = json['height'];
//     weight = json['weight'];
//     rightHanded = json['rightHanded'];
//     leftHanded = json['leftHanded'];
//     maritalStatus = json['maritalStatus'];
//     smoke = json['smoke'];
//     drinkAlcohol = json['drinkAlcohol'];
//     tattoo = json['tattoo'];
//     everSurgery = json['everSurgery'];
//     everCesareanSection = json['everCesareanSection'];
//     otherHealthRequired = json['otherHealthRequired'];
//     otherHealthRequiredAccept = json['otherHealthRequiredAccept'];
//     priorityCases = json['priorityCases'];
//     restrictionCases = json['restrictionCases'];
//     recruiMethod = json['recruiMethod'];
//     recruiContent = json['recruiContent'];
//     testFormNumber = json['testFormNumber'];
//     sendListFormDate = json['sendListFormDate'];
//     estimatedInterviewDate = json['estimatedInterviewDate'];
//     estimatedAdmissionDate = json['estimatedAdmissionDate'];
//     estimatedEntryDate = json['estimatedEntryDate'];
//     firstMonthSubsidy = json['firstMonthSubsidy'];
//     salary = json['salary'];
//     insurance = json['insurance'];
//     livingCost = json['livingCost'];
//     netMoney = json['netMoney'];
//     orderUrgent = json['orderUrgent'];
//     image = json['image'];
//     description = json['description'];
//     nominateStatus = json['nominateStatus'];
//     closeNominateUser = json['closeNominateUser'];
//     // nguoichotTiencu = json['nguoichot_tiencu'] != null ? new NguoichotTiencu.fromJson(json['nguoichot_tiencu']) : null;
//     closeNominateDate = json['closeNominateDate'];
//     orderStatusId = json['orderStatusId'];
//     // trangthaiDonhang = json['trangthai_donhang'] != null ? new TrangthaiDonhang.fromJson(json['trangthai_donhang']) : null;
//     orderBonus = json['orderBonus'];
//     aamUser = json['aamUser'];
//     // nhanvienXuly = json['nhanvien_xuly'] != null ? new NguoichotTiencu.fromJson(json['nhanvien_xuly']) : null;
//     approver = json['approver'];
//     nguoiduyetNhanvienxuly = json['nguoiduyet_nhanvienxuly'];
//     changeUserDate = json['changeUserDate'];
//     publishUser = json['publishUser'];
//     // nguoixuatban = json['nguoixuatban'] != null ? new Nguoixuatban.fromJson(json['nguoixuatban']) : null;
//     publishDate = json['publishDate'];
//     stopProcessing = json['stopProcessing'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['modifiedUser'] = this.modifiedUser;
//     data['modifiedDate'] = this.modifiedDate;
//     data['createdUser'] = this.createdUser;
//     data['createdDate'] = this.createdDate;
//     data['orderCode'] = this.orderCode;
//     data['orderName'] = this.orderName;
//     data['orgId'] = this.orgId;
//     // if (this.nghiepdoan != null) {
//     //   data['nghiepdoan'] = this.nghiepdoan!.toJson();
//     // }
//     // data['companyId'] = this.companyId;
//     // if (this.xinghiep != null) {
//     //   data['xinghiep'] = this.xinghiep!.toJson();
//     // }
//     // data['workAddress'] = this.workAddress;
//     // data['jobId'] = this.jobId;
//     // if (this.nganhnghe != null) {
//     //   data['nganhnghe'] = this.nganhnghe!.toJson();
//     // }
//     // data['jobDetailId'] = this.jobDetailId;
//     // if (this.nganhngheCuthe != null) {
//     //   data['nganhnghe_cuthe'] = this.nganhngheCuthe!.toJson();
//     // }
//     data['implementTime'] = this.implementTime;
//     data['genderRequired'] = this.genderRequired;
//     data['ageFrom'] = this.ageFrom;
//     data['ageTo'] = this.ageTo;
//     data['ttsRequired'] = this.ttsRequired;
//     data['ttsMaleRequired'] = this.ttsMaleRequired;
//     data['ttsFemaleRequired'] = this.ttsFemaleRequired;
//     data['ttsCandidates'] = this.ttsCandidates;
//     data['ttsMaleCandidates'] = this.ttsMaleCandidates;
//     data['ttsFemaleCandidates'] = this.ttsFemaleCandidates;
//     data['academicId'] = this.academicId;
//     // if (this.trinhdohocvan != null) {
//     //   data['trinhdohocvan'] = this.trinhdohocvan!.toJson();
//     // }
//     data['skill'] = this.skill;
//     data['eyeSight'] = this.eyeSight;
//     data['eyeSightGlasses'] = this.eyeSightGlasses;
//     data['eyeSightSurgery'] = this.eyeSightSurgery;
//     data['height'] = this.height;
//     data['weight'] = this.weight;
//     data['rightHanded'] = this.rightHanded;
//     data['leftHanded'] = this.leftHanded;
//     data['maritalStatus'] = this.maritalStatus;
//     data['smoke'] = this.smoke;
//     data['drinkAlcohol'] = this.drinkAlcohol;
//     data['tattoo'] = this.tattoo;
//     data['everSurgery'] = this.everSurgery;
//     data['everCesareanSection'] = this.everCesareanSection;
//     data['otherHealthRequired'] = this.otherHealthRequired;
//     data['otherHealthRequiredAccept'] = this.otherHealthRequiredAccept;
//     data['priorityCases'] = this.priorityCases;
//     data['restrictionCases'] = this.restrictionCases;
//     data['recruiMethod'] = this.recruiMethod;
//     data['recruiContent'] = this.recruiContent;
//     data['testFormNumber'] = this.testFormNumber;
//     data['sendListFormDate'] = this.sendListFormDate;
//     data['estimatedInterviewDate'] = this.estimatedInterviewDate;
//     data['estimatedAdmissionDate'] = this.estimatedAdmissionDate;
//     data['estimatedEntryDate'] = this.estimatedEntryDate;
//     data['firstMonthSubsidy'] = this.firstMonthSubsidy;
//     data['salary'] = this.salary;
//     data['insurance'] = this.insurance;
//     data['livingCost'] = this.livingCost;
//     data['netMoney'] = this.netMoney;
//     data['orderUrgent'] = this.orderUrgent;
//     data['image'] = this.image;
//     data['description'] = this.description;
//     data['nominateStatus'] = this.nominateStatus;
//     data['closeNominateUser'] = this.closeNominateUser;
//     // if (this.nguoichotTiencu != null) {
//     //   data['nguoichot_tiencu'] = this.nguoichotTiencu!.toJson();
//     // }
//     // data['closeNominateDate'] = this.closeNominateDate;
//     // data['orderStatusId'] = this.orderStatusId;
//     // if (this.trangthaiDonhang != null) {
//     //   data['trangthai_donhang'] = this.trangthaiDonhang!.toJson();
//     // }
//     // data['orderBonus'] = this.orderBonus;
//     // data['aamUser'] = this.aamUser;
//     // if (this.nhanvienXuly != null) {
//     //   data['nhanvien_xuly'] = this.nhanvienXuly!.toJson();
//     // }
//     // data['approver'] = this.approver;
//     // data['nguoiduyet_nhanvienxuly'] = this.nguoiduyetNhanvienxuly;
//     // data['changeUserDate'] = this.changeUserDate;
//     // data['publishUser'] = this.publishUser;
//     // if (this.nguoixuatban != null) {
//     //   data['nguoixuatban'] = this.nguoixuatban!.toJson();
//     // }
//     data['publishDate'] = this.publishDate;
//     data['stopProcessing'] = this.stopProcessing;
//     return data;
//   }
// }
