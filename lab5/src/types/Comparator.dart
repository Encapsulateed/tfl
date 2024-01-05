typedef Comparator<T> = bool Function(T a, T b);
final Comparator<dynamic> DEFAULT_COMPARATOR = (a, b) => a == b;