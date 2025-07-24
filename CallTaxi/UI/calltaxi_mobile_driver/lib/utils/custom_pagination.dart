import 'package:flutter/material.dart';

class CustomPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showPageSizeSelector;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int?>? onPageSizeChanged;

  const CustomPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.showPageSizeSelector = false,
    this.pageSize = 10,
    this.pageSizeOptions = const [5, 7, 10, 20, 50],
    this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int minPageSize = pageSizeOptions.isNotEmpty
        ? pageSizeOptions.first
        : 1;
    final int maxPageSize = pageSizeOptions.isNotEmpty
        ? pageSizeOptions.last
        : 100;
    final int divisions = pageSizeOptions.length > 1
        ? pageSizeOptions.length - 1
        : 1;
    int sliderValueIndex = pageSizeOptions.indexOf(pageSize);
    if (sliderValueIndex == -1) sliderValueIndex = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Page ${currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}'),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: (currentPage == 0) ? null : onPrevious,
          child: const Text('Previous'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: (currentPage >= totalPages - 1 || totalPages == 0)
              ? null
              : onNext,
          child: const Text('Next'),
        ),
        if (showPageSizeSelector) ...[
          const SizedBox(width: 30),
          Text('Rows per page:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          SizedBox(
            width: 180,
            child: Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Theme.of(context).colorScheme.primary,
                      overlayColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      valueIndicatorColor: Theme.of(
                        context,
                      ).colorScheme.primary,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      valueIndicatorShape:
                          const PaddleSliderValueIndicatorShape(),
                    ),
                    child: Slider(
                      min: 0,
                      max: (pageSizeOptions.length - 1).toDouble(),
                      divisions: divisions,
                      value: sliderValueIndex.toDouble(),
                      label: pageSizeOptions[sliderValueIndex].toString(),
                      onChanged: (double newIndex) {
                        int idx = newIndex.round();
                        if (onPageSizeChanged != null) {
                          onPageSizeChanged!(pageSizeOptions[idx]);
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    pageSizeOptions[sliderValueIndex].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
