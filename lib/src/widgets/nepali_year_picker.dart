import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

class NepaliYearPicker extends StatefulWidget {
  NepaliYearPicker({
    super.key,
    DateTime? currentDate,
    required this.firstDate,
    required this.lastDate,
    DateTime? initialDate,
    required this.selectedDate,
    required this.onChanged,
  })  : currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        initialDate = DateUtils.dateOnly(initialDate ?? selectedDate);

  /// This date is subtly highlighted in the picker.
  final DateTime currentDate;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The initial date to center the year display around.
  final DateTime initialDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<DateTime> onChanged;

  @override
  State<NepaliYearPicker> createState() => _NepaliYearPickerState();
}

class _NepaliYearPickerState extends State<NepaliYearPicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
        initialScrollOffset: _scrollOffsetForYear(widget.selectedDate));
  }

  double _scrollOffsetForYear(DateTime date) {
    final int initialYearIndex = date.year - widget.firstDate.year;
    final int initialYearRow = initialYearIndex ~/ 3;
    // Move the offset down by 2 rows to approximately center it.
    final int centeredYearRow = initialYearRow - 2;
    return _itemCount < 18 ? 0 : centeredYearRow * 52.0;
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double itemWidth = MediaQuery.of(context).size.width * 0.3;
    double itemHeight = 50;

    return Column(
      children: <Widget>[
        const Divider(),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemCount: _itemCount,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (_, index) {
              final int offset = _itemCount < 18 ? (18 - _itemCount) ~/ 2 : 0;
              final int year = widget.firstDate.year + index - offset;
              final bool isSelected = year == widget.selectedDate.year;
              final bool isCurrentYear = year == widget.currentDate.year;
              final bool isDisabled =
                  year < widget.firstDate.year || year > widget.lastDate.year;
              final Color textColor;
              BoxDecoration? decoration;

              if (isSelected) {
                textColor = colorScheme.onPrimary;
              } else if (isDisabled) {
                textColor = colorScheme.onSurface.withOpacity(0.38);
              } else if (isCurrentYear) {
                textColor = colorScheme.primary;
              } else {
                textColor = colorScheme.onSurface.withOpacity(0.87);
              }

              if (isSelected) {
                decoration = BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                );
              } else if (isCurrentYear && !isDisabled) {
                decoration = BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(18),
                );
              }

              return InkWell(
                onTap: () =>
                    widget.onChanged(DateTime(year, widget.initialDate.month)),
                child: Center(
                  child: Container(
                    decoration: decoration,
                    height: 36.0,
                    width: 72.0,
                    child: Center(
                      child: Semantics(
                        selected: isSelected,
                        button: true,
                        child: Text(
                          NepaliUnicode.convert(
                              DateTime(year, widget.initialDate.month)
                                  .toNepaliDateTime()
                                  .year
                                  .toString()),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.apply(color: textColor),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}