//
//  SSMusicTool.m
//  SingSongs
//
//  Created by Ethank on 16/4/26.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import "SSMusicTool.h"
#import <AVFoundation/AVFoundation.h>

@interface SSMusicTool ()
@property (nonatomic, strong)AVAudioPlayer *player;
@property (nonatomic, copy)NSString *currentFileName;
@property (nonatomic, assign)CGFloat *musicProgre;
@end

@implementation SSMusicTool
+ (instancetype)shareMusicTool {
    static SSMusicTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SSMusicTool alloc] init];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    });
    return instance;
}
//播放
- (void)playMusicWithFileName:(NSString *)fileName {
    if (fileName == nil) {
        return;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (filePath == nil) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if (![self.currentFileName isEqualToString:filePath]) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    }
    self.currentFileName = filePath;
    [self.player prepareToPlay];
    [self.player play];
}
//暂停
- (void)pause {
    if ([self.player isPlaying]) {
        [self.player pause];
    }
}
//当前是否正在播放
- (BOOL)isPlaying {
    return (self.player != nil && [self.player isPlaying]);
}
//获取总时长 字符串
- (NSString *)durationMusicString {
    return [NSString stringWithFormat:@"%02d:%02d", (int)self.player.duration / 60, (int)self.player.duration % 60];
}
/// 当前播放时长
-(NSString *)currentTimeString {
    return [NSString stringWithFormat:@"%02d:%02d", (int)self.player.currentTime / 60, (int)self.player.currentTime % 60];
}
-(NSTimeInterval)durationMusic {
    return self.player.duration;
}
//返回当前时长
- (NSTimeInterval)currentTime {
    return self.player.currentTime;
}
//当前进度
- (CGFloat)musicProgress {
    return self.player.currentTime / self.player.duration;
}
@end
