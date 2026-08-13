class ConfigRecord {
  ConfigRecord({
    required this.id,
    required this.name,
    required this.link,
    this.configLink = '',
    this.inboundPort = 0,
    this.status = 'Active',
    this.trafficLimitGb,
    this.expirationDays,
    DateTime? createdAtUtc,
  }) : createdAtUtc = createdAtUtc ?? DateTime.now().toUtc();

  final String id;
  final String name;
  final String link;
  final String configLink;
  final int inboundPort;
  final String status;
  final double? trafficLimitGb;
  final int? expirationDays;
  final DateTime createdAtUtc;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'link': link,
        'configLink': configLink,
        'inboundPort': inboundPort,
        'status': status,
        'trafficLimitGb': trafficLimitGb,
        'expirationDays': expirationDays,
        'createdAtUtc': createdAtUtc.toIso8601String(),
      };

  factory ConfigRecord.fromJson(Map<String, dynamic> json) {
    return ConfigRecord(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      link: json['link'] as String? ?? '',
      configLink: json['configLink'] as String? ?? '',
      inboundPort: json['inboundPort'] as int? ?? 0,
      status: json['status'] as String? ?? 'Active',
      trafficLimitGb: (json['trafficLimitGb'] as num?)?.toDouble(),
      expirationDays: json['expirationDays'] as int?,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}
