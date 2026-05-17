class StationMetadata {
  final List<String> history;
  final String? title;
  final String? art;
  final int ulisteners;
  final int listeners;
  final int bitrate;

  const StationMetadata({
    required this.history,
    this.title,
    this.art,
    required this.ulisteners,
    required this.listeners,
    required this.bitrate,
  });

  bool get isOnline {
    if (history.isEmpty) return false;
    if (title == null || title!.isEmpty) return false;
    return true;
  }

  factory StationMetadata.fromJson(Map<String, dynamic> json) {
    return StationMetadata(
      history: List<String>.from(json['history'] ?? []),
      title: json['title'] as String?,
      art: json['art'] as String?,
      ulisteners: json['ulisteners'] as int? ?? 0,
      listeners: json['listeners'] as int? ?? 0,
      bitrate: json['bitrate'] as int? ?? 0,
    );
  }

  StationMetadata copyWith({
    List<String>? history,
    String? title,
    String? art,
    int? ulisteners,
    int? listeners,
    int? bitrate,
  }) {
    return StationMetadata(
      history: history ?? this.history,
      title: title ?? this.title,
      art: art ?? this.art,
      ulisteners: ulisteners ?? this.ulisteners,
      listeners: listeners ?? this.listeners,
      bitrate: bitrate ?? this.bitrate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StationMetadata &&
        other.history.length == history.length &&
        other.history.every((e) => history.contains(e)) &&
        other.title == title &&
        other.art == art &&
        other.ulisteners == ulisteners &&
        other.listeners == listeners &&
        other.bitrate == bitrate;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(history),
      title,
      art,
      ulisteners,
      listeners,
      bitrate,
    );
  }

  @override
  String toString() {
    return 'StationMetadata(history: $history, title: $title, art: $art, '
        'ulisteners: $ulisteners, listeners: $listeners, bitrate: $bitrate)';
  }
}
