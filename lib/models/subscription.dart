class Subscription {
  final String id;
  final String name;
  final String url;
  final DateTime lastUpdate;
  final int configCount;

  Subscription({
    required this.id,
    required this.name,
    required this.url,
    required this.lastUpdate,
    this.configCount = 0,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      configCount: json['configCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'lastUpdate': lastUpdate.toIso8601String(),
      'configCount': configCount,
    };
  }

  Subscription copyWith({
    String? id,
    String? name,
    String? url,
    DateTime? lastUpdate,
    int? configCount,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      configCount: configCount ?? this.configCount,
    );
  }
}

