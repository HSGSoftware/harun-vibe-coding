class Validators {
  const Validators._();

  static String? notEmpty(String? v, {String fieldName = 'Alan'}) {
    if (v == null || v.trim().isEmpty) return '$fieldName boş olamaz';
    return null;
  }

  static String? projectName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Proje adı gerekli';
    final String name = v.trim();
    if (!RegExp(r'^[A-Za-z0-9 _-]{1,40}$').hasMatch(name)) {
      return 'Sadece harf, rakam, boşluk, "-" ve "_" kullan';
    }
    return null;
  }

  static String? gitUrl(String? v) {
    if (v == null || v.isEmpty) return 'Git URL gerekli';
    final RegExp re = RegExp(r'^(https?://|git@)[^\s]+\.git$|^https?://[^\s]+$');
    if (!re.hasMatch(v)) return 'Geçerli bir git URL\'i gir';
    return null;
  }

  static String? port(String? v) {
    if (v == null || v.isEmpty) return null;
    final int? p = int.tryParse(v);
    if (p == null || p < 1 || p > 65535) return '1-65535 arası port gir';
    return null;
  }
}
