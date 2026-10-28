class notemodel {
  String id;
  String title;
  String description;
  bool isDone;

  notemodel({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  Map<String, dynamic> tomap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
    };
  }
  factory notemodel.frommap(Map<String, dynamic> data, String id) {
    return notemodel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isDone: data['isDone'] ?? false,
    );
  }
}
