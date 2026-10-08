import 'package:meta/meta.dart';

/// Whether a given moment falls inside DeepSeek's peak traffic window.
enum TrafficState {
  peak,
  offPeak;

  bool get isPeak => this == TrafficState.peak;
}

/// Immutable snapshot describing the current traffic window.
@immutable
class TrafficStatus {
  const TrafficStatus({
    required this.state,
    required this.nextState,
    required this.timeUntilSwitch,
  });

  final TrafficState state;
  final TrafficState nextState;
  final Duration timeUntilSwitch;

  bool get isPeak => state.isPeak;

  /// Short label for when the traffic window next changes, e.g.
  /// `Off-peak in 2h 15m`. Weekends are accounted for.
  String get nextSwitchLabel {
    final next = nextState.isPeak ? 'Peak' : 'Off-peak';
    final hours = timeUntilSwitch.inHours;
    final minutes = timeUntilSwitch.inMinutes % 60;
    return '$next in ${hours}h ${minutes}m';
  }
}

/// Computes DeepSeek peak / off-peak traffic windows.
///
/// DeepSeek's schedule is defined in Beijing time (UTC+8) with peak windows at
/// **09:00–12:00** and **14:00–18:00**. Everything else is off-peak, and the
/// **entire weekend (Saturday & Sunday, Beijing time) is always off-peak**.
class PeakHoursService {
  const PeakHoursService();

  /// China Standard Time has no daylight saving, hence a fixed offset.
  static const Duration _beijingOffset = Duration(hours: 8);

  /// Peak windows expressed as `[startHour, endHour)` in Beijing wall-clock
  /// time. Kept in a single place so the schedule is easy to adjust.
  static const List<List<int>> _peakWindows = [
    [9, 12],
    [14, 18],
  ];

  TrafficStatus statusAt(DateTime now) {
    final utc = now.toUtc();
    final state = _stateAt(utc);
    final (nextState, remaining) = _nextSwitch(utc, state);
    return TrafficStatus(
      state: state,
      nextState: nextState,
      timeUntilSwitch: remaining,
    );
  }

  TrafficStatus statusNow() => statusAt(DateTime.now());

  static TrafficState _stateAt(DateTime utc) {
    final beijing = utc.add(_beijingOffset);

    // Weekends are always off-peak.
    if (_isWeekend(beijing)) return TrafficState.offPeak;

    final hour = beijing.hour;
    for (final window in _peakWindows) {
      if (hour >= window[0] && hour < window[1]) {
        return TrafficState.peak;
      }
    }
    return TrafficState.offPeak;
  }

  static bool _isWeekend(DateTime beijing) =>
      beijing.weekday == DateTime.saturday ||
      beijing.weekday == DateTime.sunday;

  /// Finds the next moment the state differs from [current] by scanning
  /// forward minute by minute (bounded to 4 days so weekends are covered).
  (TrafficState, Duration) _nextSwitch(DateTime utc, TrafficState current) {
    const maxMinutes = 60 * 24 * 4;
    for (var minute = 1; minute <= maxMinutes; minute++) {
      final moment = utc.add(Duration(minutes: minute));
      final state = _stateAt(moment);
      if (state != current) {
        return (state, Duration(minutes: minute));
      }
    }
    return (current, Duration.zero);
  }
}
