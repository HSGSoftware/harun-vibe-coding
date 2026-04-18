import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/api_paths.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/entities/usage_stats.dart';

final usageProvider = FutureProvider.autoDispose<({List<UsageDay> days, double total})>((ref) async {
  final res = await ref.read(apiClientProvider).get<Map<String, dynamic>>(ApiPaths.aiUsage);
  final raw = (res.data?['daily'] as List?) ?? const [];
  final days = raw.map((e) => UsageDay.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  final total = ((res.data?['total'] ?? 0) as num).toDouble();
  return (days: days, total: total);
});

class UsageDashboardPage extends ConsumerWidget {
  const UsageDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(usageProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanım & Maliyet')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) => data.days.isEmpty
            ? const EmptyState(title: 'Henüz kullanım verisi yok', icon: Icons.bar_chart)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Toplam', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text(Formatters.cost(data.total),
                              style: Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: data.days.length,
                      itemBuilder: (_, i) {
                        final d = data.days[i];
                        return ListTile(
                          title: Text('${d.day} · ${d.provider}/${d.model}'),
                          subtitle: Text('in: ${d.tokensIn}  out: ${d.tokensOut}  cache: ${d.cacheTokens}'),
                          trailing: Text(Formatters.cost(d.costUsd)),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
