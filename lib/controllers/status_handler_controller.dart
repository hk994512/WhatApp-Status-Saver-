import 'package:get/get.dart';
import 'package:wa_saver/globals/config.dart';

class StatusHandlerController extends GetxController {
  RxInt totalStatuses = 0.obs;
  RxInt countStatuses = 0.obs;
  int getTotalStatuses(int numsStatuses) {
    return totalStatuses.value = numsStatuses;
  }

 dynamic notificationHandler({bool? isToggled}) {
    if (countStatuses.value < totalStatuses.value) {
      NotificationService.toggleNotifications(isToggled ?? true);
    }
  }
}
