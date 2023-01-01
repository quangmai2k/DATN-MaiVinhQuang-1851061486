//Chỉ cần truyển vào listUser vì trong user đã có nghiện đoàn
import '../../../../model/market_development/user.dart';

Map<int, List<User>> nhomDanhSachThucTapSinhTheoTungNghiepDoan(List<User> listUser) {
  Map<int, List<User>> map = {};
  for (var item in listUser) {
    if (item.order != null && item.order!.union != null) {
      if (!map.containsKey(item.order!.union!.id)) {
        List<User> listUserTrungNghiepDoan = [];
        listUserTrungNghiepDoan.add(item);
        map.putIfAbsent(item.order!.union!.id!, () => listUserTrungNghiepDoan);
      } else {
        map[item.order!.union!.id!]!.add(item);
      }
    }
  }
  return map;
}
