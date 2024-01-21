typedef Comparator<T> = bool Function(T a, T b);
final Comparator<dynamic> DEFAULT_COMPARATOR = (dynamic a, dynamic b) {
  if (a is List<dynamic> && b is List<dynamic>) {
    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }

  return a == b;
};
