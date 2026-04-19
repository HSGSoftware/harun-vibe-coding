/// Seed prompts loaded into the library on first run. Keep lean — users extend
/// from here via the chat UI (see plan.md §11.16).
class DefaultPrompts {
  const DefaultPrompts._();

  static const List<Map<String, String>> seeds = [
    {
      'title': 'Hata Analizi',
      'content':
          'Aşağıdaki hatayı analiz et ve en olası sebebi kısaca açıkla. '
              'Sonra düzeltme için diff öner.\n\n[HATA]',
      'tags': 'hata,analiz',
    },
    {
      'title': 'Kodu Açıkla',
      'content':
          'Bu kodu satır satır açıkla. Teknik terimleri bağlamla birlikte kullan.\n\n[KOD]',
      'tags': 'kod,açıklama',
    },
    {
      'title': 'Refactor Öner',
      'content':
          'Bu fonksiyonun okunabilirliğini ve test edilebilirliğini artıracak '
              'refactor önerileri çıkar. Öneriyi diff olarak sun.',
      'tags': 'refactor',
    },
    {
      'title': 'Test Yaz',
      'content':
          'Bu dosya için birim testleri yaz. Edge case\'lere ve mutlu yola ayrı '
              'testler ekle. Framework projede kullanılanla aynı olsun.',
      'tags': 'test',
    },
  ];
}
