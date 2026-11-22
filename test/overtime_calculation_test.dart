import 'package:flutter_test/flutter_test.dart';
import 'package:overtime_calculator/src/overtime_calculation.dart';

void main() {
  group('calculateOvertime', () {
    test('uses 225 monthly hours for morning shifts', () {
      final result = calculateOvertime(
        const OvertimeInput(
          salary: 2250,
          fivePercentHours: 2,
          dayHours: 2,
          nightHours: 4,
          shift: WorkShift.morning,
          category: 1,
        ),
      );

      expect(result.hourlyRate, 10);
      expect(result.rawFivePercentAmount, 25);
      expect(result.fivePercentAmount, 25);
      expect(result.dayAmount, 25);
      expect(result.nightAmount, 60);
      expect(result.total, 110);
      expect(result.isFivePercentCapped, isFalse);
    });

    test('uses 180 monthly hours and applies the category 5 ceiling', () {
      final result = calculateOvertime(
        const OvertimeInput(
          salary: 1800,
          fivePercentHours: 50,
          dayHours: 1,
          nightHours: 1,
          shift: WorkShift.rotating,
          category: 5,
        ),
      );

      expect(result.hourlyRate, 10);
      expect(result.rawFivePercentAmount, 625);
      expect(result.fivePercentAmount, 549);
      expect(result.dayAmount, 12.5);
      expect(result.nightAmount, 15);
      expect(result.total, 576.5);
      expect(result.isFivePercentCapped, isTrue);
    });

    test('uses the correct five-percent ceiling for every category', () {
      expect(categoryFivePercentCeilings[1], 704.5);
      expect(categoryFivePercentCeilings[2], 621.5);
      expect(categoryFivePercentCeilings[3], 592.5);
      expect(categoryFivePercentCeilings[4], 592.5);
      expect(categoryFivePercentCeilings[5], 549);
    });

    test('keeps zero-hour amounts at zero and still builds a total step', () {
      final result = calculateOvertime(
        const OvertimeInput(
          salary: 0,
          fivePercentHours: 0,
          dayHours: 0,
          nightHours: 0,
          shift: WorkShift.morning,
          category: 1,
        ),
      );

      expect(result.total, 0);
      expect(result.breakdownSteps, hasLength(2));
      expect(result.breakdownSteps.last.isTotal, isTrue);
    });

    test('shows breakdown rows only for entered overtime types', () {
      final result = calculateOvertime(
        const OvertimeInput(
          salary: 1000,
          fivePercentHours: 1,
          dayHours: 0,
          nightHours: 3,
          shift: WorkShift.morning,
          category: 2,
        ),
      );

      expect(result.breakdownSteps.map((step) => step.title), <String>[
        'حساب قيمة ساعة الأساس',
        'حساب الإضافي 5%',
        'حساب الإضافي الليلي',
        'المجموع الكلي',
      ]);
    });

    test('rejects negative or non-finite values', () {
      const base = OvertimeInput(
        salary: 1000,
        fivePercentHours: 0,
        dayHours: 0,
        nightHours: 0,
        shift: WorkShift.morning,
        category: 1,
      );

      expect(
        () => calculateOvertime(
          const OvertimeInput(
            salary: -1,
            fivePercentHours: 0,
            dayHours: 0,
            nightHours: 0,
            shift: WorkShift.morning,
            category: 1,
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => calculateOvertime(
          OvertimeInput(
            salary: double.infinity,
            fivePercentHours: base.fivePercentHours,
            dayHours: base.dayHours,
            nightHours: base.nightHours,
            shift: base.shift,
            category: base.category,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
