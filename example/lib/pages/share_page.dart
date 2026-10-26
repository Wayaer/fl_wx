import 'dart:io';

import 'package:example/demo/samples.dart';
import 'package:example/widgets/api_card.dart';
import 'package:fl_wx/fl_wx.dart';
import 'package:flutter/material.dart';

class SharePage extends StatelessWidget {
  const SharePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiList(
      intro: '文本、图片、小程序、音乐、视频、网页、文件和表情分享。示例图片使用内置的 PNG 字节数据。',
      actions: [
        ApiAction(
          icon: Icons.text_fields_rounded,
          title: 'shareText',
          description: '分享文本，包含全部可选参数。',
          code: r'''final result = await FlWx().shareText(
  'Hello from fl_wx',
  title: 'fl_wx',
  description: 'A simple Flutter wrapper for fluwx',
  scene: WeChatScene.session,
  messageExt: 'messageExt',
  messageAction: 'messageAction',
  mediaTagName: 'mediaTagName',
  msgSignature: 'msgSignature',
  thumbData: sampleImageBytes,
  thumbDataHash: 'thumbDataHash',
);''',
          action: () async => await FlWx().shareText(
            'Hello from fl_wx',
            title: 'fl_wx',
            description: 'A simple Flutter wrapper for fluwx',
            messageExt: 'messageExt',
            messageAction: 'messageAction',
            mediaTagName: 'mediaTagName',
            msgSignature: 'msgSignature',
            thumbData: sampleImageBytes,
            thumbDataHash: 'thumbDataHash',
          ),
        ),
        ApiAction(
          icon: Icons.movie_filter_rounded,
          title: '分享到朋友圈',
          description: '通过 scene 指定分享目标。',
          code: r'''final result = await FlWx().shareText(
  '分享到朋友圈',
  scene: WeChatScene.timeline,
);''',
          action: () async => await FlWx().shareText('分享到朋友圈', scene: WeChatScene.timeline),
        ),
        ApiAction(
          icon: Icons.share_rounded,
          title: 'share(WeChatShareTextModel)',
          description: '使用通用 share 方法分享任意分享模型。',
          code: r'''final result = await FlWx().share(
  WeChatShareTextModel('Hello from fl_wx'),
);''',
          action: () async => await FlWx().share(WeChatShareTextModel('Hello from fl_wx')),
        ),
        ApiAction(
          icon: Icons.image_rounded,
          title: 'shareImage',
          description: '分享图片，并携带小程序入口参数。',
          code: r'''final result = await FlWx().shareImage(
  WeChatImageToShare(
    uint8List: sampleImageBytes,
    imgDataHash: 'hash',
  ),
  title: 'fl_wx',
  description: '分享图片',
  entranceMiniProgramUsername: 'gh_xxxxxxxx',
  entranceMiniProgramPath: '/pages/index',
  thumbData: sampleImageBytes,
);''',
          action: () async => await FlWx().shareImage(
            WeChatImageToShare(uint8List: sampleImageBytes, imgDataHash: 'hash'),
            title: 'fl_wx',
            description: '分享图片',
            entranceMiniProgramUsername: 'gh_xxxxxxxx',
            entranceMiniProgramPath: '/pages/index',
            thumbData: sampleImageBytes,
          ),
        ),
        ApiAction(
          icon: Icons.grid_view_rounded,
          title: 'shareMiniProgram',
          description: '分享小程序卡片，包含全部可选参数。',
          code: r'''final result = await FlWx().shareMiniProgram(
  webPageUrl: 'https://example.com',
  userName: 'gh_xxxxxxxx',
  path: '/pages/index',
  miniProgramType: WXMiniProgramType.release,
  title: '小程序标题',
  description: '小程序描述',
  withShareTicket: true,
  hdImageData: sampleImageBytes,
  thumbData: sampleImageBytes,
);''',
          action: () async => await FlWx().shareMiniProgram(
            webPageUrl: 'https://example.com',
            userName: 'gh_xxxxxxxx',
            path: '/pages/index',
            miniProgramType: WXMiniProgramType.release,
            title: '小程序标题',
            description: '小程序描述',
            withShareTicket: true,
            hdImageData: sampleImageBytes,
            thumbData: sampleImageBytes,
          ),
        ),
        ApiAction(
          icon: Icons.music_note_rounded,
          title: 'shareMusic',
          description: '分享音乐，高低码率地址可同时传入。',
          code: r'''final result = await FlWx().shareMusic(
  musicUrl: 'https://example.com/music.mp3',
  musicDataUrl: 'https://example.com/music.mp3',
  musicLowBandUrl: 'https://example.com/music-low.mp3',
  musicLowBandDataUrl: 'https://example.com/music-low.mp3',
  title: '音乐标题',
  description: '音乐描述',
  thumbData: sampleImageBytes,
);''',
          action: () async => await FlWx().shareMusic(
            musicUrl: 'https://example.com/music.mp3',
            musicDataUrl: 'https://example.com/music.mp3',
            musicLowBandUrl: 'https://example.com/music-low.mp3',
            musicLowBandDataUrl: 'https://example.com/music-low.mp3',
            title: '音乐标题',
            description: '音乐描述',
            thumbData: sampleImageBytes,
          ),
        ),
        ApiAction(
          icon: Icons.videocam_rounded,
          title: 'shareVideo',
          description: '分享视频，可携带标题和缩略图。',
          code: r'''final result = await FlWx().shareVideo(
  'https://example.com/video.mp4',
  title: '视频标题',
  description: '视频描述',
  thumbData: sampleImageBytes,
);''',
          action: () async => await FlWx().shareVideo(
            'https://example.com/video.mp4',
            title: '视频标题',
            description: '视频描述',
            thumbData: sampleImageBytes,
          ),
        ),
        ApiAction(
          icon: Icons.language_rounded,
          title: 'shareWebPage',
          description: '分享网页链接。',
          code: r'''final result = await FlWx().shareWebPage(
  'https://github.com/Wayaer/fl_wx',
  title: 'fl_wx',
  description: 'Flutter 微信封装',
  scene: WeChatScene.session,
  thumbData: sampleImageBytes,
);''',
          action: () async => await FlWx().shareWebPage(
            'https://github.com/Wayaer/fl_wx',
            title: 'fl_wx',
            description: 'Flutter 微信封装',
            thumbData: sampleImageBytes,
          ),
        ),
        ApiAction(
          icon: Icons.slow_motion_video_rounded,
          title: 'share(WeChatShareVideoModel)',
          description: '通过通用 share 分享低码率视频。',
          code: r'''final result = await FlWx().share(
  WeChatShareVideoModel(
    videoLowBandUrl: 'https://example.com/video-low.mp4',
    title: '低码率视频',
  ),
);''',
          action: () async => await FlWx().share(
            WeChatShareVideoModel(videoLowBandUrl: 'https://example.com/video-low.mp4', title: '低码率视频'),
          ),
        ),
        ApiAction(
          icon: Icons.insert_drive_file_rounded,
          title: 'shareFile',
          description: '分享本地文件，iOS 需要指定 suffix。',
          code: r'''final file = File('${Directory.systemTemp.path}/fl_wx_example.txt');
await file.writeAsString('Hello from fl_wx');
final result = await FlWx().shareFile(
  file,
  suffix: '.txt',
  title: 'fl_wx 文件',
);''',
          action: () async {
            final file = File('${Directory.systemTemp.path}/fl_wx_example.txt');
            await file.writeAsString('Hello from fl_wx');
            return FlWx().shareFile(file, suffix: '.txt', title: 'fl_wx 文件');
          },
        ),
        ApiAction(
          icon: Icons.emoji_emotions_rounded,
          title: 'share(WeChatShareEmojiModel)',
          description: '分享微信表情。',
          code: r'''final result = await FlWx().share(
  WeChatShareEmojiModel(
    WeChatImageToShare(uint8List: sampleImageBytes),
  ),
);''',
          action: () async =>
              await FlWx().share(WeChatShareEmojiModel(WeChatImageToShare(uint8List: sampleImageBytes))),
        ),
        ApiAction(
          icon: Icons.link_rounded,
          title: 'share(WeChatFile.network)',
          description: '通过通用 share 分享网络文件。',
          code: r'''final result = await FlWx().share(
  WeChatShareFileModel(
    WeChatFile.network(
      'https://example.com/file.pdf',
      suffix: '.pdf',
    ),
    title: '网络文件',
  ),
);''',
          action: () async => await FlWx().share(
            WeChatShareFileModel(WeChatFile.network('https://example.com/file.pdf', suffix: '.pdf'), title: '网络文件'),
          ),
        ),
      ],
    );
  }
}
