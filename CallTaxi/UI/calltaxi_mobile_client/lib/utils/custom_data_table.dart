import 'package:flutter/material.dart';

class CustomDataTableCard extends StatelessWidget {
  final double width;
  final double height;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? emptyState;
  final IconData? emptyIcon;
  final String? emptyText;
  final String? emptySubtext;
  final bool showCheckboxColumn;
  final double columnSpacing;
  final Color? headingRowColor;
  final Color? hoverRowColor;
  final EdgeInsetsGeometry? padding;

  const CustomDataTableCard({
    super.key,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    this.emptyState,
    this.emptyIcon,
    this.emptyText,
    this.emptySubtext,
    this.showCheckboxColumn = false,
    this.columnSpacing = 24,
    this.headingRowColor,
    this.hoverRowColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = rows.isEmpty;
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          child: isEmpty
              ? (emptyState ?? _defaultEmptyState())
              : SizedBox(
                  height: height - 32, // account for padding
                  child: SingleChildScrollView(
                    child: DataTable(
                      showCheckboxColumn: showCheckboxColumn,
                      columnSpacing: columnSpacing,
                      headingRowColor: headingRowColor != null
                          ? WidgetStateProperty.all(headingRowColor)
                          : WidgetStateProperty.resolveWith<Color?>(
                              (states) => Colors.blue[50],
                            ),
                      dataRowColor: hoverRowColor != null
                          ? WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.hovered)
                                  ? hoverRowColor
                                  : null,
                            )
                          : WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.hovered)
                                  ? Colors.blue.withAlpha(20)
                                  : null,
                            ),
                      columns: columns,
                      rows: rows,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _defaultEmptyState() {
    if (emptyIcon == null && emptyText == null && emptySubtext == null) {
      return Center(child: Text('No data'));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emptyIcon != null)
            Icon(emptyIcon, size: 48, color: Colors.grey[400]),
          if (emptyText != null) ...[
            SizedBox(height: 16),
            Text(
              emptyText!,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
          if (emptySubtext != null) ...[
            SizedBox(height: 8),
            Text(
              emptySubtext!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
