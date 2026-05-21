import '../models/song.dart';
import '../models/playlist.dart';

// 演示数据生成器
// 用于开发和测试时生成假数据
class DemoData {
  // 生成演示歌曲列表
  static List<Song> getDemoSongs() {
    return [
      Song(
        id: 1,
        title: '成都',
        artist: '赵雷',
        album: '赵雷',
        path: 'assets/songs/chengdu.mp3',
        duration: const Duration(minutes: 4, seconds: 30),
        isLocal: true,
      ),
      Song(
        id: 2,
        title: '南山南',
        artist: '马頔',
        album: '南山南',
        path: 'assets/songs/nanshannan.mp3',
        duration: const Duration(minutes: 5, seconds: 10),
        isLocal: true,
      ),
      Song(
        id: 3,
        title: '海阔天空',
        artist: 'Beyond',
        album: '乐与怒',
        path: 'assets/songs/haikuotiankong.mp3',
        duration: const Duration(minutes: 5, seconds: 45),
        isLocal: true,
      ),
      Song(
        id: 4,
        title: '光年之外',
        artist: 'G.E.M. 邓紫棋',
        album: '光年之外',
        path: 'assets/songs/guangnianzai.mp3',
        duration: const Duration(minutes: 3, seconds: 50),
        isLocal: true,
      ),
      Song(
        id: 5,
        title: '夜曲',
        artist: '周杰伦',
        album: '叶惠美',
        path: 'assets/songs/yequ.mp3',
        duration: const Duration(minutes: 4, seconds: 20),
        isLocal: true,
      ),
      Song(
        id: 6,
        title: '青花瓷',
        artist: '周杰伦',
        album: '依然范特西',
        path: 'assets/songs/qinghuaci.mp3',
        duration: const Duration(minutes: 4, seconds: 40),
        isLocal: true,
      ),
      Song(
        id: 7,
        title: '海靠',
        artist: ' 것은',
        album: '海靠',
        path: 'assets/songs/haikao.mp3',
        duration: const Duration(minutes: 4, seconds: 15),
        isLocal: true,
      ),
      Song(
        id: 8,
        title: 'essa',
        artist: 'Yorushika',
        album: 'Fantastic Planet',
        path: 'assets/songs/essa.mp3',
        duration: const Duration(minutes: 3, seconds: 45),
        isLocal: true,
      ),
    ];
  }

  // 生成演示歌单
  static List<Playlist> getDemoPlaylists() {
    return [
      Playlist(
        id: 1,
        name: '我喜欢',
        description: '收藏的音乐',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        songIds: [1, 3, 5, 7],
      ),
      Playlist(
        id: 2,
        name: '华语精选',
        description: '优质的华语歌曲',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        songIds: [1, 2, 4, 5, 6],
      ),
      Playlist(
        id: 3,
        name: '放松时光',
        description: '轻松惬意的音乐',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        songIds: [2, 4, 8],
      ),
    ];
  }

  // 生成演示LRC歌词
  static String getDemoLyric() {
    return '''
[00:00.00] 成都
[00:03.50] 作詞：李石
[00:07.00] 作曲：李石
[00:10.50] 演唱：赵雷

[00:15.00] 我曾经怎样elf偷偷地爱过你
[00:20.00] 早已将那短短的情话写成诗
[00:25.00] 我曾经怎样傻傻地等过你
[00:30.00] 早已将那长长的夜晚熬成纸

[00:35.00] 我仿佛看见我的旧日充满着
[00:40.00] 我们人们的爱和思念
[00:45.00]  satisfactory blindness
[00:50.00]  But absence of life

[00:55.00] 我仿佛看见我的旧日充满着
[01:00.00] 我们人们的爱和思
[01:05.00] 我仿佛看见我的旧日充满着
[01:10.00] 我们
    ''';
  }
}
