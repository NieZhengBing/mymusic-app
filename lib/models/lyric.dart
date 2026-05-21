// 歌词行模型
class LyricLine {
  final Duration time; // 时间点
  final String text; // 歌词文本

  LyricLine({required this.time, required this.text});

  @override
  String toString() => 'LyricLine(${time.inMilliseconds}ms: $text)';
}

// 歌词模型
class Lyric {
  final List<LyricLine> lines;

  Lyric({required this.lines});

  // 获取当前时间的歌词
  String getLyricAt(Duration position) {
    for (int i = 0; i < lines.length; i++) {
      if (position >= lines[i].time &&
          (i == lines.length - 1 || position < lines[i + 1].time)) {
        return lines[i].text;
      }
    }
    return '';
  }

  // 获取当前歌词的索引
  int getCurrentIndex(Duration position) {
    for (int i = 0; i < lines.length; i++) {
      if (position >= lines[i].time &&
          (i == lines.length - 1 || position < lines[i + 1].time)) {
        return i;
      }
    }
    return -1;
  }

  // 是否有歌词
  bool get isEmpty => lines.isEmpty;

  @override
  String toString() => 'Lyric(lines: ${lines.length})';
}
