import 'package:rc/core/constants.dart';

class RadioStation {
  final String name;
  final String url;
  final String? port;
  final String? logo;
  final String? slogan;

  const RadioStation({
    required this.name,
    required this.url,
    this.port,
    this.logo,
    this.slogan,
  });

  RadioStation copyWith({
    String? name,
    String? url,
    String? port,
    String? logo,
    String? slogan,
  }) {
    return RadioStation(
      name: name ?? this.name,
      url: url ?? this.url,
      port: port ?? this.port,
      logo: logo ?? this.logo,
      slogan: slogan ?? this.slogan,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadioStation &&
        other.name == name &&
        other.url == url &&
        other.port == port &&
        other.logo == logo &&
        other.slogan == slogan;
  }

  @override
  int get hashCode {
    return Object.hash(name, url, port, logo, slogan);
  }

  @override
  String toString() {
    return 'RadioStation(name: $name, url: $url, port: $port, logo: $logo, slogan: $slogan)';
  }

  String get streamUrl {
    if (port == null || port!.isEmpty) {
      return url;
    }
    final host = Uri.parse(ApiConstants.server).host;
    return 'http://$host:$port/stream';
  }
}