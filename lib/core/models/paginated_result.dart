/// Generic paginated result wrapper for list data
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  bool get hasMore => (currentPage * pageSize) < totalCount;

  int get totalPages => (totalCount / pageSize).ceil();

  PaginatedResult<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? currentPage,
    int? pageSize,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
