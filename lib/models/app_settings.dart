enum PlayStyle { quick, study }

class AppSettings {
  const AppSettings({required this.playStyle});

  final PlayStyle playStyle;

  int get secondsPerQuestion => playStyle == PlayStyle.quick ? 30 : 60;

  AppSettings copyWith({PlayStyle? playStyle}) {
    return AppSettings(playStyle: playStyle ?? this.playStyle);
  }

  Map<String, dynamic> toJson() {
    return {'playStyle': playStyle.name};
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawStyle = json['playStyle'] as String?;
    final style = PlayStyle.values.firstWhere(
      (value) => value.name == rawStyle,
      orElse: () => PlayStyle.quick,
    );
    return AppSettings(playStyle: style);
  }

  static const defaults = AppSettings(playStyle: PlayStyle.quick);
}
