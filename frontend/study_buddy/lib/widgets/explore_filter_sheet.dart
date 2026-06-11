import 'package:flutter/material.dart';
import '../models/explore_filter.dart';
import '../theme/app_theme.dart';

class ExploreFilterSheet extends StatefulWidget {
  final ExploreFilter currentFilter;
  final Function(ExploreFilter) onApply;

  const ExploreFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late ExploreFilter _filter;

  final List<String> _subjects = [
    'Machine Learning',
    'Data Structures',
    'Flutter',
    'Java',
    'Python',
    'DBMS',
    'System Design',
    'Web Dev',
    'Deep Learning',
    'NLP',
    'React',
  ];

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'PG',
  ];

  final List<String> _studyModes = ['Online', 'Offline', 'Both'];

  final List<String> _examTargets = [
    'Placement',
    'GATE',
    'CAT',
    'UPSC',
    'GRE',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _filter = ExploreFilter(
      subject: widget.currentFilter.subject,
      year: widget.currentFilter.year,
      studyMode: widget.currentFilter.studyMode,
      examTarget: widget.currentFilter.examTarget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Students',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() => _filter.clear());
                },
                child: const Text('Clear all',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject
                  _FilterSection(
                    title: 'Subject',
                    options: _subjects,
                    selected: _filter.subject,
                    onSelect: (v) => setState(() => _filter = _filter.copyWith(
                        subject: v, clearSubject: _filter.subject == v)),
                  ),
                  const SizedBox(height: 20),

                  // Year
                  _FilterSection(
                    title: 'Year',
                    options: _years,
                    selected: _filter.year,
                    onSelect: (v) => setState(() => _filter = _filter.copyWith(
                        year: v, clearYear: _filter.year == v)),
                  ),
                  const SizedBox(height: 20),

                  // Study mode
                  _FilterSection(
                    title: 'Study Mode',
                    options: _studyModes,
                    selected: _filter.studyMode,
                    onSelect: (v) => setState(() => _filter = _filter.copyWith(
                        studyMode: v, clearStudyMode: _filter.studyMode == v)),
                  ),
                  const SizedBox(height: 20),

                  // Exam target
                  _FilterSection(
                    title: 'Exam Target',
                    options: _examTargets,
                    selected: _filter.examTarget,
                    onSelect: (v) => setState(() => _filter = _filter.copyWith(
                        examTarget: v,
                        clearExamTarget: _filter.examTarget == v)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Apply button
          ElevatedButton(
            onPressed: () {
              widget.onApply(_filter);
              Navigator.pop(context);
            },
            child: Text(
              _filter.isActive
                  ? 'Apply ${_filter.activeCount} filter${_filter.activeCount > 1 ? "s" : ""}'
                  : 'Apply Filters',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final Function(String) onSelect;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
