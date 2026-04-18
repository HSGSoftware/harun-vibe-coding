class UsageDay {
  const UsageDay({
    required this.day,
    required this.provider,
    required this.model,
    this.tokensIn = 0,
    this.tokensOut = 0,
    this.cacheTokens = 0,
    this.costUsd = 0,
  });

  final String day;
  final String provider;
  final String model;
  final int tokensIn;
  final int tokensOut;
  final int cacheTokens;
  final double costUsd;

  factory UsageDay.fromJson(Map<String, dynamic> json) {
    return UsageDay(
      day: json['Day'] as String? ?? json['day'] as String? ?? '',
      provider: json['Provider'] as String? ?? json['provider'] as String? ?? '',
      model: json['Model'] as String? ?? json['model'] as String? ?? '',
      tokensIn: (json['TokensIn'] ?? json['tokens_in'] ?? 0) as int,
      tokensOut: (json['TokensOut'] ?? json['tokens_out'] ?? 0) as int,
      cacheTokens: (json['CacheTokens'] ?? json['cache_tokens'] ?? 0) as int,
      costUsd: ((json['CostUSD'] ?? json['cost_usd'] ?? 0) as num).toDouble(),
    );
  }
}
