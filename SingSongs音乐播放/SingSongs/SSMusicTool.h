//
//  SSMusicTool.h
//  SingSongs
//
//  Created by Ethank on 16/4/26.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSMusicTool : NSObject
+(instancetype)shareMusicTool;
/// 播放
/// @param name 歌曲名称
- (void)playMusicWithFileName:(NSString *)fileName;
/// 暂停
-(void)pause;
//当前是否正在播放
- (BOOL)isPlaying;
/// 歌曲总时长字符串
-(NSString *)durationMusicString;
/// 总时长
-(NSTimeInterval)durationMusic;
/// 当前播放时长
-(NSString *)currentTimeString;
/// 当前时长
-(NSTimeInterval)currentTime;
/// 进度
-(CGFloat)musicProgress;
@end
