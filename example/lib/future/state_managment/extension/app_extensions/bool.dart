import 'package:onchain_swap_example/future/state_managment/state_managment.dart';

extension QuickBooleanExtension on bool {
  String get tr {
    if (this) return "yes".tr;
    return "no".tr;
  }
}
