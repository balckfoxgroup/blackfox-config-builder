class InboundInfo {
  const InboundInfo({
    required this.id,
    required this.protocol,
    required this.remark,
    required this.port,
    required this.enable,
  });

  final int id;
  final String protocol;
  final String remark;
  final int port;
  final bool enable;

  factory InboundInfo.fromJson(Map<String, dynamic> json) {
    return InboundInfo(
      id: json['id'] as int? ?? 0,
      protocol: (json['protocol'] as String?)?.trim() ?? '',
      remark: (json['remark'] as String?)?.trim() ?? '',
      port: json['port'] as int? ?? 0,
      enable: json['enable'] as bool? ?? false,
    );
  }
}
