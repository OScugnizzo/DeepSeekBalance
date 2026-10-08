import 'package:deepseekbalance/services/peak_hours_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = PeakHoursService();

  // Beijing = UTC+8. 2026-10-08 is a Thursday, 10-10 a Saturday,
  // 10-11 a Sunday and 10-12 a Monday.
  DateTime utc(int day, int hour, [int minute = 0]) =>
      DateTime.utc(2026, 10, day, hour, minute);

  group('PeakHoursService weekday windows', () {
    test('is peak during Beijing 09:00-12:00', () {
      // 02:00 UTC == 10:00 Beijing, Thursday.
      expect(service.statusAt(utc(8, 2)).state, TrafficState.peak);
    });

    test('is peak during Beijing 14:00-18:00', () {
      // 07:00 UTC == 15:00 Beijing, Thursday.
      expect(service.statusAt(utc(8, 7)).state, TrafficState.peak);
    });

    test('is off-peak around the peak windows', () {
      // 00:00 UTC == 08:00 Beijing
      expect(service.statusAt(utc(8, 0)).state, TrafficState.offPeak);
      // 05:00 UTC == 13:00 Beijing
      expect(service.statusAt(utc(8, 5)).state, TrafficState.offPeak);
      // 12:00 UTC == 20:00 Beijing
      expect(service.statusAt(utc(8, 12)).state, TrafficState.offPeak);
    });
  });

  group('PeakHoursService weekends are always off-peak', () {
    test('Saturday midday is off-peak even inside a peak window', () {
      // 02:00 UTC == 10:00 Beijing, Saturday.
      expect(service.statusAt(utc(10, 2)).state, TrafficState.offPeak);
      // 07:00 UTC == 15:00 Beijing, Saturday.
      expect(service.statusAt(utc(10, 7)).state, TrafficState.offPeak);
    });

    test('Sunday is off-peak all day', () {
      expect(service.statusAt(utc(11, 2)).state, TrafficState.offPeak);
      expect(service.statusAt(utc(11, 7)).state, TrafficState.offPeak);
    });

    test('Monday morning becomes peak again', () {
      // 02:00 UTC == 10:00 Beijing, Monday.
      expect(service.statusAt(utc(12, 2)).state, TrafficState.peak);
    });
  });

  group('PeakHoursService next switch', () {
    test('reports the upcoming state and a readable label', () {
      final status = service.statusAt(utc(8, 2));
      expect(status.isPeak, isTrue);
      expect(status.nextState, TrafficState.offPeak);
      expect(status.timeUntilSwitch, greaterThan(Duration.zero));
      expect(
        status.nextSwitchLabel,
        matches(RegExp(r'^(Peak|Off-peak) in \d+h \d+m$')),
      );
    });

    test('from a weekday peak the next switch is a few hours away', () {
      // Thursday 10:00 Beijing -> 12:00 Beijing is 2h away.
      final status = service.statusAt(utc(8, 2));
      expect(status.nextState, TrafficState.offPeak);
      expect(status.timeUntilSwitch, const Duration(hours: 2));
    });

    test('on the weekend the next switch lands on Monday peak', () {
      // Saturday 10:00 Beijing -> next change Monday 09:00 Beijing.
      final status = service.statusAt(utc(10, 2));
      expect(status.nextState, TrafficState.peak);
      expect(
        status.timeUntilSwitch,
        const Duration(hours: 47),
      );
    });
  });
}
