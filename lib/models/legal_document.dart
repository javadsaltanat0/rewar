/// One heading + body block of a legal document, e.g. "YOUR AGREEMENT".
class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;

  static LegalSection? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final heading = raw['heading'];
    final body = raw['body'];
    if (heading is! String || body is! String) return null;
    return LegalSection(heading: heading, body: body);
  }
}

/// A versioned legal document (Terms of Service, Privacy Policy) held in the
/// `legal_documents` Firestore collection so the wording can be updated from
/// the admin panel without an app-store release — which is what the Terms
/// text itself promises.
///
/// [version] is the part that matters operationally: consent is recorded
/// against it (`users.termsVersion`), so when the wording changes you can
/// tell exactly who agreed to which text and re-prompt only those who
/// haven't seen the current one.
class LegalDocument {
  const LegalDocument({
    required this.version,
    required this.updatedAt,
    required this.sections,
    required this.legalReviewed,
  });

  final int version;
  final DateTime? updatedAt;
  final List<LegalSection> sections;

  /// False until a qualified translator/lawyer has signed off the wording.
  /// Surfaced in the UI so an unreviewed document can't ship unnoticed.
  final bool legalReviewed;

  /// Reads the document for [languageCode], falling back to English when a
  /// translation is missing — never showing an empty legal page.
  static LegalDocument? fromMap(
    Map<String, dynamic>? data,
    String languageCode,
  ) {
    if (data == null) return null;
    final content = data['content'];
    if (content is! Map) return null;

    final localized = content[languageCode] ?? content['en'];
    if (localized is! Map) return null;

    final rawSections = localized['sections'];
    if (rawSections is! List) return null;

    final sections = rawSections
        .map(LegalSection.tryParse)
        .whereType<LegalSection>()
        .toList();
    if (sections.isEmpty) return null;

    final rawUpdatedAt = data['updatedAt'];
    return LegalDocument(
      version: (data['version'] as num?)?.toInt() ?? 1,
      // Accepts a Firestore Timestamp (which exposes toDate()) without this
      // model needing to depend on cloud_firestore.
      updatedAt: switch (rawUpdatedAt) {
        DateTime dt => dt,
        final dynamic ts when ts != null => _tryToDate(ts),
        _ => null,
      },
      sections: sections,
      legalReviewed: data['legalReviewed'] == true,
    );
  }

  static DateTime? _tryToDate(dynamic value) {
    try {
      return value.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
