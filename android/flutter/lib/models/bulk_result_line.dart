class BulkResultLine {
  const BulkResultLine({
    required this.index,
    required this.name,
    required this.configLink,
    required this.subLink,
  });

  final int index;
  final String name;
  final String configLink;
  final String subLink;

  factory BulkResultLine.fromJson(Map<String, dynamic> json) {
    return BulkResultLine(
      index: json['index'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      configLink: json['configLink'] as String? ?? '',
      subLink: json['subLink'] as String? ?? '',
    );
  }
}
