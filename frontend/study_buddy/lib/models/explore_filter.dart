class ExploreFilter {
  String? subject;
  String? year;
  String? studyMode; // Online / Offline / Both
  String? examTarget; // GATE, Placement, CAT, UPSC, General

  ExploreFilter({
    this.subject,
    this.year,
    this.studyMode,
    this.examTarget,
  });

  bool get isActive =>
      subject != null ||
      year != null ||
      studyMode != null ||
      examTarget != null;

  int get activeCount =>
      [subject, year, studyMode, examTarget].where((f) => f != null).length;

  ExploreFilter copyWith({
    String? subject,
    String? year,
    String? studyMode,
    String? examTarget,
    bool clearSubject = false,
    bool clearYear = false,
    bool clearStudyMode = false,
    bool clearExamTarget = false,
  }) {
    return ExploreFilter(
      subject: clearSubject ? null : subject ?? this.subject,
      year: clearYear ? null : year ?? this.year,
      studyMode: clearStudyMode ? null : studyMode ?? this.studyMode,
      examTarget: clearExamTarget ? null : examTarget ?? this.examTarget,
    );
  }

  void clear() {
    subject = null;
    year = null;
    studyMode = null;
    examTarget = null;
  }
}
