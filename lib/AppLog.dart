class AppLog {
  static final List<String> logs = [];

  static void add(String message) {
    final time = DateTime.now().toString().substring(11, 19);
    logs.add('[$time] $message');
    if (logs.length > 300) logs.removeAt(0);
  }
}