import 'dart:io';
import '../models/lyric.dart';

// 歌词解析器
// 支持 LRC 格式
class LyricParser {
  // 解析LRC格式歌词
  static Lyric parseLrc(String lrcText) {
    final lines = <LyricLine>[];

    // 匹配 [mm:ss.ff] 或 [mm:ss] 格式
    // 示例: [00:12.34]这是第一句歌词
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{0,3})\](.*)');

    for (var line in lrcText.split('\n')) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = match.group(3) != null
            ? int.parse(match.group(3)!.padLeft(3, '0')).clamp(0, 999)
            : 0;
        final text = match.group(4)!.trim();

        // 计算总毫秒数
        final totalMilliseconds = minutes * 60000 + seconds * 1000 + milliseconds;

        lines.add(LyricLine(
          time: Duration(milliseconds: totalMilliseconds),
          text: text,
        ));
      }
    }

    return Lyric(lines: lines);
  }

  // 解析KRC格式（简化，只提取文本）
  static Lyric parseKrc(String krcText) {
    // KRC格式比较复杂，这里只做简单处理
    // 实际应用中可以考虑更完整的解析器
    final lines = <LyricLine>[];

    // 按行分割
    var time = Duration.zero;
    for (var line in krcText.split('\n')) {
      // 跳过空行
      if (line.trim().isEmpty) continue;

      // 简单添加（时间需要根据KRC格式解析）
      lines.add(LyricLine(time: time, text: line.trim()));
      time += const Duration(seconds: 1);
    }

    return Lyric(lines: lines);
  }

  // 从文件路径加载歌词
  // 尝试加载 .lrc 或 .krc 文件
  static Future<Lyric?> loadLyricFromFile(String songPath) async {
    // 替换扩展名
    final lrcPath = songPath.replaceAll(RegExp(r'\.[^.]+$'), '.lrc');
    final krcPath = songPath.replaceAll(RegExp(r'\.[^.]+$'), '.krc');

    // 尝试加载 LRC 文件
    final lrcFile = File(lrcPath);
    if (await lrcFile.exists()) {
      try {
        final content = await lrcFile.readAsString();
        return parseLrc(content);
      } catch (e) {
        print('读取LRC文件失败: $e');
      }
    }

    // 尝试加载 KRC 文件
    final krcFile = File(krcPath);
    if (await krcFile.exists()) {
      try {
        final content = await krcFile.readAsString();
        return parseKrc(content);
      } catch (e) {
        print('读取KRC文件失败: $e');
      }
    }

    return null;
  }
}
