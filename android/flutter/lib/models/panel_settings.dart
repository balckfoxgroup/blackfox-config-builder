class PanelSettings {
  const PanelSettings({
    this.panelUrl = '',
    this.username = '',
    this.password = '',
    this.apiKey = '',
    this.subUri = '',
  });

  final String panelUrl;
  final String username;
  final String password;
  final String apiKey;
  final String subUri;

  Map<String, dynamic> toJson() => {
        'panelUrl': panelUrl,
        'username': username,
        'password': password,
        'apiKey': apiKey,
        'subUri': subUri,
      };

  factory PanelSettings.fromJson(Map<String, dynamic> json) {
    return PanelSettings(
      panelUrl: json['panelUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      subUri: json['subUri'] as String? ?? '',
    );
  }

  PanelSettings copyWith({
    String? panelUrl,
    String? username,
    String? password,
    String? apiKey,
    String? subUri,
  }) {
    return PanelSettings(
      panelUrl: panelUrl ?? this.panelUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      apiKey: apiKey ?? this.apiKey,
      subUri: subUri ?? this.subUri,
    );
  }
}
