class BuildNumber {
  BuildNumber._();

  static int parse(String raw) {
    return normalize(int.tryParse(raw.trim()) ?? 0);
  }

  static int normalize(int raw) {
    if (raw <= 0) {
      return raw;
    }
    if (raw >= 1000) {
      final suffix = raw % 1000;
      if (suffix > 0) {
        return suffix;
      }
    }
    return raw;
  }
}
