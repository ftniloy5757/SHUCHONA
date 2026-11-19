import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/responsive_cards.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/blood_alert/blood_alert_provider.dart';

/// Module 18: Privacy-Preserving NGO / Public Health Admin Impact Dashboard.
/// Strictly anonymized, PII-stripped population health analytics powered by `fl_chart`:
/// - Zero-PII confirmation badge
/// - Active SHG Members & Offline Check-ins
/// - Top Anonymized Symptom Clusters by Upazila
/// - Total Estimated Patient Medication Savings (BDT ৳) via PrescribeSafe BD
/// - Blood Demand Alert Fulfillment Rate & Average Donor Response Time
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _selectedRegion = 'All';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final session = ref.watch(userSessionProvider);
    final blood = ref.watch(bloodNetworkProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final multiplier = switch (_selectedRegion) {
      'Savar' => 0.42,
      'Cumilla' => 0.31,
      'Bogura' => 0.27,
      _ => 1.0,
    };

    final activeMembers = (1482 * multiplier).round();
    final offlineCheckins = (18940 * multiplier).round();
    final totalSavingsBdt =
        (482500 * multiplier).round() + session.cumulativeBdtSaved.round();
    final bloodFulfillment = _selectedRegion == 'Savar' ? 96.4 : 94.2;
    final avgResponseMin = _selectedRegion == 'Savar' ? 9.8 : 11.4;

    final symptomClusters = [
      (
        labelBn: 'PCOS/চক্র',
        labelEn: 'PCOS/Cycle',
        count: (412 * multiplier).round(),
      ),
      (
        labelBn: 'রক্তশূন্যতা',
        labelEn: 'Anemia',
        count: (368 * multiplier).round(),
      ),
      (
        labelBn: 'মাতৃস্বাস্থ্য',
        labelEn: 'Maternal',
        count: (245 * multiplier).round(),
      ),
      (
        labelBn: 'স্তন যত্ন',
        labelEn: 'Breast',
        count: (164 * multiplier).round(),
      ),
      (
        labelBn: 'মানসিক চাপ',
        labelEn: 'Stress',
        count: (289 * multiplier).round(),
      ),
    ];

    final briefingSpeech = s.tr(
      'এনজিও ও জনস্বাস্থ্য ইমপ্যাক্ট ড্যাশবোর্ড। এখানে কোনো ব্যক্তিগত পরিচয় বা ফোন নম্বর সংরক্ষিত নেই। মোট সক্রিয় স্বনির্ভর দল সদস্য ${s.formatDigits(activeMembers.toString())} জন, PrescribeSafe BD জেনেরিক ওষুধে আনুমানিক সাশ্রয় ${s.formatTaka(totalSavingsBdt)}, এবং জরুরি রক্ত SOS সফলতার হার ${s.formatDigits(bloodFulfillment.toString())} শতাংশ, গড় সাড়া সময় ${s.formatDigits(avgResponseMin.toString())} মিনিট।',
      'NGO and Public Health Impact Dashboard. Zero PII stored; all identifiers stripped on-device. Active Self-Help Group members: $activeMembers. Estimated patient medication savings via PrescribeSafe BD: $totalSavingsBdt Taka. Blood SOS fulfillment rate: $bloodFulfillment% with average donor response time of $avgResponseMin minutes.',
    );

    return Scaffold(
      appBar: ShuchonaAppBar(
        title: s.tr('অ্যাডমিন ড্যাশবোর্ড', 'Admin Impact'),
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
        children: [
          // EXPLICIT ZERO-PII PRIVACY GUARANTEE BADGE
          AccessibleCard(
            backgroundColor: isDark
                ? AppColors.darkEmeraldBg
                : AppColors.secondaryEmeraldLight,
            borderColor: AppColors.secondaryEmerald,
            borderWidth: 1.6,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.secondaryEmerald,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.zeroPiiBadge,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : AppColors.secondaryEmeraldDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TtsListenButton(
                      textToSpeak: briefingSpeech,
                      compact: true,
                      accentColor: AppColors.secondaryEmeraldDark,
                      tag: 'admin_briefing',
                      labelOverride: s.tr('রিপোর্ট শুনুন', 'Impact Briefing'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(56, 46),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: () {
                        ref.read(adminRoleProvider.notifier).state = false;
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(Icons.person_rounded, size: 18),
                      label: Text(s.tr('কমিউনিটি ভিউ', 'User View')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Upazila Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    ('All', s.tr('সারা বাংলাদেশ', 'All Upazilas')),
                    ('Savar', s.tr('সাভার, ঢাকা', 'Savar')),
                    ('Cumilla', s.tr('কুমিল্লা সদর', 'Cumilla')),
                    ('Bogura', s.tr('বগুড়া সদর', 'Bogura')),
                  ].map((region) {
                    final selected = _selectedRegion == region.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selected,
                        label: Text(
                          region.$2,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedRegion = region.$1),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Executive KPI Tiles
          ResponsiveCards(
            children: [
              _KpiTile(
                icon: Icons.groups_rounded,
                accent: primary,
                label: s.tr('সক্রিয় SHG সদস্য', 'Active SHG Members'),
                value: s.formatDigits(activeMembers.toString()),
                sub: s.tr(
                  '${s.formatDigits(offlineCheckins.toString())} অফলাইন চেক-ইন',
                  '$offlineCheckins offline check-ins',
                ),
              ),
              _KpiTile(
                icon: Icons.savings_rounded,
                accent: AppColors.secondaryEmerald,
                label: s.tr('রোগীদের ওষুধ সাশ্রয়', 'Est. Rx Generic Savings'),
                value: s.formatTaka(totalSavingsBdt),
                sub: s.tr(
                  'PrescribeSafe BD (গড়ে ৪৩%)',
                  'PrescribeSafe BD (~43%)',
                ),
              ),
              _KpiTile(
                icon: Icons.bloodtype_rounded,
                accent: AppColors.alertCrimson,
                label: s.tr('রক্ত SOS সফলতা', 'Blood SOS Fulfillment'),
                value: '${s.formatDigits(bloodFulfillment.toString())}%',
                sub: s.tr(
                  'গড় সাড়া: ${s.formatDigits(avgResponseMin.toString())} মিনিট',
                  'Avg response: $avgResponseMin min',
                ),
              ),
              _KpiTile(
                icon: Icons.trending_up_rounded,
                accent: AppColors.cautionAmber,
                label: s.tr(
                  '৩০-দিনের অভ্যাস রিটেনশন',
                  '30-Day Habit Retention',
                ),
                value: '+${s.formatDigits("44")}%',
                sub: s.tr(
                  'সক্রিয় SOS: ${s.formatDigits(blood.activeRequests.length.toString())}',
                  'Live SOS requests: ${blood.activeRequests.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // CHART 1: Top Anonymized Symptom Clusters by Upazila (BarChart)
          AccessibleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    'শীর্ষ নামহীন লক্ষণ ক্লাস্টার (উপজেলা ভিত্তিক)',
                    'Top Anonymized Symptom Clusters by Upazila',
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  s.tr(
                    'জনস্বাস্থ্য ও মেডিকেল ক্যাম্প পরিকল্পনার জন্য সমষ্টিগত ডেটা',
                    'Aggregated trends for Upazila clinic staffing & maternal outreach',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (460 * multiplier).ceilToDouble().clamp(50, 500),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.45),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (val, _) => Text(
                              s.formatDigits(val.toInt().toString()),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (val, _) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= symptomClusters.length) {
                                return const SizedBox.shrink();
                              }
                              final c = symptomClusters[idx];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  s.tr(c.labelBn, c.labelEn),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: symptomClusters.asMap().entries.map((e) {
                        final colors = [
                          primary,
                          AppColors.roseAccent,
                          AppColors.secondaryEmerald,
                          AppColors.cautionAmber,
                          AppColors.indigoSoft,
                        ];
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.count.toDouble(),
                              color: colors[e.key % colors.length],
                              width: 24,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CHART 2: Monthly PrescribeSafe BD Medication Savings Growth (LineChart)
          AccessibleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    'মাসিক জেনেরিক ওষুধ সাশ্রয় প্রবৃদ্ধি (হাজার টাকায় ৳)',
                    'Monthly PrescribeSafe BD Savings Trend (in BDT ৳k)',
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 185,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 150,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 50,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.45),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 50,
                            reservedSize: 42,
                            getTitlesWidget: (v, _) => Text(
                              '৳${s.formatDigits(v.toInt().toString())}k',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (v, _) {
                              const monthsBn = [
                                'জুন',
                                'জুলাই',
                                'আগ',
                                'সেপ্ট',
                                'অক্টো',
                                'নভে',
                              ];
                              const monthsEn = [
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                              ];
                              final i = v.toInt();
                              if (i < 0 || i >= monthsEn.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  s.isBn ? monthsBn[i] : monthsEn[i],
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: AppColors.secondaryEmerald,
                          barWidth: 3.5,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.secondaryEmerald.withValues(
                              alpha: 0.16,
                            ),
                          ),
                          spots: [
                            FlSpot(0, 38 * multiplier),
                            FlSpot(1, 56 * multiplier),
                            FlSpot(2, 74 * multiplier),
                            FlSpot(3, 98 * multiplier),
                            FlSpot(4, 121 * multiplier),
                            FlSpot(5, 148 * multiplier),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // NRB Clinical & Pharmacist Validation Portal Status (From Proposal!)
          AccessibleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SeverityBadge(
                  label: s.tr(
                    'NRB ক্লিনিক্যাল ও ফার্মাসিস্ট ভ্যালিডেশন',
                    'NRB Clinician & Pharmacist Audit Status',
                  ),
                  tone: BadgeTone.clinicalTeal,
                  icon: Icons.public_rounded,
                ),
                const SizedBox(height: 8),
                Text(
                  s.tr(
                    'প্রবাসী বাংলাদেশি চিকিৎসক ও ফার্মাসিস্টদের যাচাইকৃত DGDA/DIMS DDI গ্রাফ',
                    'Audited DGDA/DIMS Drug-Interaction Graph & Bangla ICD-11 Mapping',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  s.tr(
                    '• ৪২+ স্থানীয় বাংলাদেশি ব্র্যান্ড ও জেনেরিক যাচাইকৃত\n• <৮৫% OCR কনফিডেন্স গেট ১০০% কার্যকর\n• ১,০৪৮টি সম্ভাব্য DDI/দ্বৈত ওষুধ ঝুঁকি প্রতিরোধ',
                    '• 42+ Bangladeshi DGDA brands & generics verified\n• <85% OCR Confidence Gate active on 100% of scans\n• 1,048 potential DDI & duplicate-ingredient risks intercepted',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.sub,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
