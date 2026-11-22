enum WorkShift {
  morning,
  rotating;

  int get monthlyHours => this == WorkShift.morning ? 225 : 180;

  String get arabicLabel => this == WorkShift.morning
      ? 'دوام صباحي = 225 ساعة شهرياً'
      : 'دوام ورادي = 180 ساعة شهرياً';
}

class OvertimeInput {
  const OvertimeInput({
    required this.salary,
    required this.fivePercentHours,
    required this.dayHours,
    required this.nightHours,
    required this.shift,
    required this.category,
  });

  final double salary;
  final double fivePercentHours;
  final double dayHours;
  final double nightHours;
  final WorkShift shift;
  final int category;
}

class OvertimeBreakdownStep {
  const OvertimeBreakdownStep({
    required this.number,
    required this.title,
    required this.formula,
    required this.equation,
    this.note,
    this.isTotal = false,
  });

  final int number;
  final String title;
  final String formula;
  final String equation;
  final String? note;
  final bool isTotal;
}

class OvertimeResult {
  const OvertimeResult({
    required this.input,
    required this.hourlyRate,
    required this.categoryCeiling,
    required this.rawFivePercentAmount,
    required this.fivePercentAmount,
    required this.dayAmount,
    required this.nightAmount,
    required this.total,
    required this.isFivePercentCapped,
  });

  final OvertimeInput input;
  final double hourlyRate;
  final double categoryCeiling;
  final double rawFivePercentAmount;
  final double fivePercentAmount;
  final double dayAmount;
  final double nightAmount;
  final double total;
  final bool isFivePercentCapped;

  List<OvertimeBreakdownStep> get breakdownSteps {
    final divisor = input.shift.monthlyHours;
    final steps = <OvertimeBreakdownStep>[
      OvertimeBreakdownStep(
        number: 1,
        title: 'حساب قيمة ساعة الأساس',
        formula: 'الراتب المقطوع ÷ $divisor = قيمة ساعة الأساس',
        equation:
            '${formatInputNumber(input.salary)} ÷ $divisor = ${formatMoney(hourlyRate)} ل.س',
        note: '(${input.shift.arabicLabel})',
      ),
    ];

    var number = 2;
    if (input.fivePercentHours > 0) {
      steps.add(
        OvertimeBreakdownStep(
          number: number++,
          title: 'حساب الإضافي 5%',
          formula: 'قيمة ساعة الأساس × 1.25 × عدد ساعات 5% = قيمة الإضافي 5%',
          equation:
              '${formatMoney(hourlyRate)} × 1.25 × ${formatInputNumber(input.fivePercentHours)} = ${formatMoney(rawFivePercentAmount)} ل.س',
          note:
              'سقف الفئة ${input.category}: 5% × ${formatInputNumber(categoryCeilingBasis[input.category]!)} = ${formatMoney(categoryCeiling)} ل.س${isFivePercentCapped ? ' — تم تطبيق السقف' : ''}',
        ),
      );
    }
    if (input.dayHours > 0) {
      steps.add(
        OvertimeBreakdownStep(
          number: number++,
          title: 'حساب الإضافي النهاري',
          formula:
              'قيمة ساعة الأساس × 1.25 × عدد ساعات النهاري = قيمة الإضافي النهاري',
          equation:
              '${formatMoney(hourlyRate)} × 1.25 × ${formatInputNumber(input.dayHours)} = ${formatMoney(dayAmount)} ل.س',
        ),
      );
    }
    if (input.nightHours > 0) {
      steps.add(
        OvertimeBreakdownStep(
          number: number++,
          title: 'حساب الإضافي الليلي',
          formula:
              'قيمة ساعة الأساس × 1.50 × عدد ساعات الليلي = قيمة الإضافي الليلي',
          equation:
              '${formatMoney(hourlyRate)} × 1.50 × ${formatInputNumber(input.nightHours)} = ${formatMoney(nightAmount)} ل.س',
        ),
      );
    }

    steps.add(
      OvertimeBreakdownStep(
        number: number,
        title: 'المجموع الكلي',
        formula: 'إضافي 5% + إضافي نهاري + إضافي ليلي = المجموع',
        equation:
            '${formatMoney(fivePercentAmount)} + ${formatMoney(dayAmount)} + ${formatMoney(nightAmount)} = ${formatMoney(total)} ل.س',
        isTotal: true,
      ),
    );
    return steps;
  }
}

const Map<int, double> categoryCeilingBasis = <int, double>{
  1: 14090,
  2: 12430,
  3: 11850,
  4: 11850,
  5: 10980,
};

const Map<int, double> categoryFivePercentCeilings = <int, double>{
  1: 704.5,
  2: 621.5,
  3: 592.5,
  4: 592.5,
  5: 549,
};

OvertimeResult calculateOvertime(OvertimeInput input) {
  if (!categoryCeilingBasis.containsKey(input.category)) {
    throw ArgumentError.value(input.category, 'category', 'الفئة غير معروفة');
  }
  _requireNonNegative(input.salary, 'salary');
  _requireNonNegative(input.fivePercentHours, 'fivePercentHours');
  _requireNonNegative(input.dayHours, 'dayHours');
  _requireNonNegative(input.nightHours, 'nightHours');

  final hourlyRate = input.salary / input.shift.monthlyHours;
  final ceiling = categoryFivePercentCeilings[input.category]!;
  final rawFivePercent = hourlyRate * 1.25 * input.fivePercentHours;
  final capped = rawFivePercent > ceiling;
  final fivePercent = capped ? ceiling : rawFivePercent;
  final day = hourlyRate * 1.25 * input.dayHours;
  final night = hourlyRate * 1.5 * input.nightHours;

  return OvertimeResult(
    input: input,
    hourlyRate: hourlyRate,
    categoryCeiling: ceiling,
    rawFivePercentAmount: rawFivePercent,
    fivePercentAmount: fivePercent,
    dayAmount: day,
    nightAmount: night,
    total: fivePercent + day + night,
    isFivePercentCapped: capped,
  );
}

void _requireNonNegative(double value, String field) {
  if (!value.isFinite || value < 0) {
    throw ArgumentError.value(value, field, 'يجب أن تكون القيمة غير سالبة');
  }
}

String formatMoney(double value) => value.toStringAsFixed(2);

String formatInputNumber(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

String toArabicDigits(int value) {
  const digits = <String>['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return value.toString().split('').map((character) {
    final digit = int.tryParse(character);
    return digit == null ? character : digits[digit];
  }).join();
}
