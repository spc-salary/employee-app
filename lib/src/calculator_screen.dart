import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overtime_calculator/src/overtime_calculation.dart';
import 'package:url_launcher/url_launcher.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const Uri _websiteUri = Uri(
    scheme: 'https',
    host: 'spc-salary.github.io',
    path: '/apps/',
  );
  static const double _cardRadius = 22;

  final _salaryController = TextEditingController();
  final _fivePercentController = TextEditingController();
  final _dayController = TextEditingController();
  final _nightController = TextEditingController();
  final GlobalKey<State<StatefulWidget>> _resultsKey =
      GlobalKey<State<StatefulWidget>>();

  WorkShift _shift = WorkShift.morning;
  int _category = 1;
  bool _ceilingsOpen = false;
  bool _breakdownOpen = false;
  OvertimeResult? _result;

  @override
  void dispose() {
    _salaryController.dispose();
    _fivePercentController.dispose();
    _dayController.dispose();
    _nightController.dispose();
    super.dispose();
  }

  Future<void> _openWebsite() async {
    final didLaunch = await launchUrl(
      _websiteUri,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الموقع حالياً')));
    }
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final result = calculateOvertime(
      OvertimeInput(
        salary: _readNumber(_salaryController),
        fivePercentHours: _readNumber(_fivePercentController),
        dayHours: _readNumber(_dayController),
        nightHours: _readNumber(_nightController),
        shift: _shift,
        category: _category,
      ),
    );

    setState(() {
      _result = result;
      _breakdownOpen = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _resultsKey.currentContext;
      if (targetContext != null && mounted) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
    });
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    _salaryController.clear();
    _fivePercentController.clear();
    _dayController.clear();
    _nightController.clear();
    setState(() {
      _shift = WorkShift.morning;
      _category = 1;
      _result = null;
      _breakdownOpen = false;
    });
  }

  double _readNumber(TextEditingController controller) {
    var value = controller.text.trim();
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    for (var index = 0; index < eastern.length; index++) {
      value = value.replaceAll(eastern[index], '$index');
    }
    value = value.replaceAll('٫', '.').replaceAll('٬', '').replaceAll(',', '.');
    return double.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 16.0 : 24.0;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHeader(context),
                      const SizedBox(height: 18),
                      _buildEmployeeCard(context),
                      const SizedBox(height: 14),
                      _buildInputsCard(context),
                      const SizedBox(height: 14),
                      _buildActions(context),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _result == null
                            ? const SizedBox.shrink(
                                key: ValueKey<String>('empty'),
                              )
                            : Padding(
                                key: _resultsKey,
                                padding: const EdgeInsets.only(top: 18),
                                child: _buildResults(context, _result!),
                              ),
                      ),
                      const SizedBox(height: 20),
                      _buildFooter(context, theme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final gradient = widget.isDark
        ? const <Color>[Color(0xFF102747), Color(0xFF0B3A67)]
        : const <Color>[
            Color(0xFF0B3C70),
            Color(0xFF1A5EA8),
            Color(0xFF2679D4),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withAlpha(widget.isDark ? 35 : 45),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            end: -30,
            top: -43,
            child: _HeaderOrb(size: 142, opacity: 0.07),
          ),
          PositionedDirectional(
            start: 46,
            bottom: -64,
            child: _HeaderOrb(size: 132, opacity: 0.055),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(19, 18, 12, 18),
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.white.withAlpha(28),
                  borderRadius: BorderRadius.circular(17),
                  child: InkWell(
                    onTap: _openWebsite,
                    borderRadius: BorderRadius.circular(17),
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(
                        Icons.local_gas_station_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: InkWell(
                    onTap: _openWebsite,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'مديرية غاز جنوب المنطقة الوسطى',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.35,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'نظام حساب الإضافي للموظفين',
                            style: TextStyle(
                              color: Color(0xFFD6E7FA),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  onPressed: widget.onToggleTheme,
                  tooltip: widget.isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                  icon: Icon(
                    widget.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(24),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(44, 44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SectionHeading(
            icon: Icons.badge_outlined,
            title: 'بيانات الموظف',
            subtitle: 'اختر طبيعة الدوام والفئة',
          ),
          const SizedBox(height: 17),
          _responsiveFields(context, <Widget>[
            _FormField(
              label: 'طبيعة الدوام',
              child: DropdownButtonFormField<WorkShift>(
                initialValue: _shift,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
                items: const <DropdownMenuItem<WorkShift>>[
                  DropdownMenuItem(
                    value: WorkShift.morning,
                    child: Text('صباحي'),
                  ),
                  DropdownMenuItem(
                    value: WorkShift.rotating,
                    child: Text('ورادي'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _shift = value);
                  }
                },
              ),
            ),
            _FormField(
              label: 'الفئة',
              child: DropdownButtonFormField<int>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: List<DropdownMenuItem<int>>.generate(
                  5,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('فئة ${toArabicDigits(index + 1)}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 15),
          _buildCeilings(context),
        ],
      ),
    );
  }

  Widget _buildCeilings(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(
          widget.isDark ? 72 : 115,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(120)),
      ),
      child: Column(
        children: <Widget>[
          Semantics(
            button: true,
            expanded: _ceilingsOpen,
            child: InkWell(
              onTap: () => setState(() => _ceilingsOpen = !_ceilingsOpen),
              borderRadius: BorderRadius.circular(17),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 11, 13),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'سقوف الفئات — الحد الأعلى للإضافي 5%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _ceilingsOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 230),
            curve: Curves.easeOutCubic,
            child: _ceilingsOpen
                ? Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      12,
                      0,
                      12,
                      12,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const columns = 3;
                        const gap = 8.0;
                        final cellWidth =
                            (constraints.maxWidth - gap * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: List<Widget>.generate(5, (index) {
                            final category = index + 1;
                            final isActive = category == _category;
                            return SizedBox(
                              width: cellWidth,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? colorScheme.primary.withAlpha(24)
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActive
                                        ? colorScheme.primary.withAlpha(115)
                                        : colorScheme.outlineVariant.withAlpha(
                                            90,
                                          ),
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'فئة ${toArabicDigits(category)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isActive
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${formatMoney(categoryFivePercentCeilings[category]!)} ل.س',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: isActive
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildInputsCard(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SectionHeading(
            icon: Icons.payments_outlined,
            title: 'ساعات الإضافي والراتب',
            subtitle: 'أدخل القيم المطلوبة للحساب',
            accent: true,
          ),
          const SizedBox(height: 17),
          _responsiveFields(context, <Widget>[
            _numberField(
              label: 'راتب التعويضات',
              hint: 'أدخل الراتب المقطوع',
              controller: _salaryController,
              icon: Icons.account_balance_wallet_outlined,
              allowDecimal: true,
            ),
            _numberField(
              label: 'عدد ساعات 5%',
              hint: 'أدخل عدد الساعات',
              controller: _fivePercentController,
              icon: Icons.percent_rounded,
            ),
            _numberField(
              label: 'عدد ساعات النهاري',
              hint: 'أدخل عدد الساعات',
              controller: _dayController,
              icon: Icons.wb_sunny_outlined,
            ),
            _numberField(
              label: 'عدد ساعات الليلي',
              hint: 'أدخل عدد الساعات',
              controller: _nightController,
              icon: Icons.nightlight_outlined,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool allowDecimal = false,
  }) {
    return _FormField(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: allowDecimal,
          signed: false,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫٬]')),
        ],
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _responsiveFields(BuildContext context, List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 13.0;
        final columns = constraints.maxWidth < 520 ? 1 : 2;
        final fieldWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 13,
          children: fields
              .map((field) => SizedBox(width: fieldWidth, child: field))
              .toList(),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 400;
        return Row(
          children: <Widget>[
            Expanded(
              flex: compact ? 6 : 5,
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('احسب الإضافي'),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              flex: compact ? 5 : 4,
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('إعادة تعيين'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, OvertimeResult result) {
    return Column(
      key: const ValueKey<String>('calculation-results'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _SectionHeading(
                icon: Icons.query_stats_rounded,
                title: 'نتائج الحساب',
                subtitle: 'المبالغ المحتسبة للإضافي',
                accent: true,
              ),
              const SizedBox(height: 13),
              if (result.fivePercentAmount != 0)
                _ResultLine(
                  icon: Icons.percent_rounded,
                  label: 'الإضافي 5%',
                  amount: result.fivePercentAmount,
                  capped: result.isFivePercentCapped,
                ),
              if (result.dayAmount != 0)
                _ResultLine(
                  icon: Icons.wb_sunny_outlined,
                  label: 'الإضافي النهاري',
                  amount: result.dayAmount,
                ),
              if (result.nightAmount != 0)
                _ResultLine(
                  icon: Icons.nightlight_outlined,
                  label: 'الإضافي الليلي',
                  amount: result.nightAmount,
                ),
              const SizedBox(height: 8),
              _buildTotal(context, result.total),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildBreakdownCard(context, result),
      ],
    );
  }

  Widget _buildTotal(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(17, 17, 17, 17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withBlue(135),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: <Widget>[
          const Text(
            'المجموع الكلي للإضافي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: formatMoney(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        fontFeatures: <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const TextSpan(
                      text: '  ليرة سورية',
                      style: TextStyle(
                        color: Color(0xFFDDEBFA),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(BuildContext context, OvertimeResult result) {
    final scheme = Theme.of(context).colorScheme;
    return _AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Semantics(
            button: true,
            expanded: _breakdownOpen,
            child: InkWell(
              onTap: () => setState(() => _breakdownOpen = !_breakdownOpen),
              borderRadius: BorderRadius.circular(_cardRadius),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(17, 16, 13, 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.primary.withAlpha(22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'طريقة الحساب بالتفصيل',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _breakdownOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _breakdownOpen
                ? Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      17,
                      0,
                      17,
                      13,
                    ),
                    child: Column(
                      children: result.breakdownSteps
                          .map((step) => _BreakdownRow(step: step))
                          .toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Column(
      children: <Widget>[
        Text(
          'تصميم وتطوير wm.hn',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '© ${DateTime.now().year} مديرية غاز جنوب المنطقة الوسطى',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withAlpha(175),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HeaderOrb extends StatelessWidget {
  const _HeaderOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((opacity * 255).round()),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(19),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_CalculatorScreenState._cardRadius),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(100)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ? scheme.secondary : scheme.primary;
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: 7),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.icon,
    required this.label,
    required this.amount,
    this.capped = false,
  });

  final IconData icon;
  final String label;
  final double amount;
  final bool capped;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueColor = capped ? const Color(0xFFD97706) : scheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: <Widget>[
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: valueColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: valueColor, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 7,
              runSpacing: 4,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (capped)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: valueColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'مسقوف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: formatMoney(amount),
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: '  ل.س',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.step});

  final OvertimeBreakdownStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = step.isTotal ? scheme.primary : scheme.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsetsDirectional.only(top: 1),
            decoration: BoxDecoration(
              color: color.withAlpha(step.isTotal ? 31 : 19),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              toArabicDigits(step.number),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  step.title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withAlpha(
                      Theme.of(context).brightness == Brightness.dark
                          ? 60
                          : 115,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    border: BorderDirectional(
                      start: BorderSide(color: color, width: 3),
                    ),
                  ),
                  child: Text(
                    step.formula,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      step.equation,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (step.note != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    step.note!,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
