import '../apps/models/LocationInfo.dart';
import '../models/Adhan.dart';
import 'adhanProvider.dart';
import 'dependencies/AdhanDependencyProvider.dart';

class AdhanNotificationProvider extends AdhanProvider {
  AdhanNotificationProvider(
    AdhanDependencyProvider adhanDependencyProvider,
    LocationInfo locationInfo,
  ) : super(adhanDependencyProvider, locationInfo);

  Adhan? get notificationAdhan {
    final list = getAdhanData(DateTime.now())
      ..forEach((element) {
        element.modifyForNotification();
      });

    return list.firstWhere(
      (element) =>
          element.isCurrent &&
          (adhanDependencyProvider.showPersistant ||
              adhanDependencyProvider.notifyID(element.type) != 0),
      orElse: () => null as Adhan,
    );
  }

  Adhan? get nextNotifcationAdhan {
    final List<Adhan> fullList = [];
    final currentTime = DateTime.now();
    fullList.addAll(getAdhanData(currentTime));
    fullList.addAll(getAdhanData(DateTime.now().add(const Duration(days: 1))));
    fullList.addAll(getAdhanData(DateTime.now().add(const Duration(days: 2))));

    for (var element in fullList) {
      element.modifyForNotification();
    }

    final filteredList = fullList
        .where(
          (element) =>
              element.startTime.isAfter(currentTime) &&
              (adhanDependencyProvider.showPersistant ||
                  adhanDependencyProvider.notifyID(element.type) != 0),
        )
        .toList();

    if (filteredList.isNotEmpty) {
      return filteredList[0];
    } else {
      return null;
    }
  }
}
