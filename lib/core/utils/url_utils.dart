String normalizeUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return trimmed;
  }

  if (uri.hasScheme) {
    return trimmed;
  }

  return 'https://$trimmed';
}
