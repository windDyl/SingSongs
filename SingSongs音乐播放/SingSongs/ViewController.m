//
//  ViewController.m
//  SingSongs
//
//  Created by Ethank on 16/4/26.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "SSMusicTool.h"
#import "SSLyricTool.h"
#import "SSMusicModel.h"
#import "SSLyricModel.h"
#import "SSLabel.h"
#import <MediaPlayer/MediaPlayer.h>

#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define kLrcLineHeight 44

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, weak)UIButton *lastMusicBtn;
@property (nonatomic, weak)UIButton *startOrStopBtn;
@property (nonatomic, weak)UIButton *nextMusicBtn;

@property (weak, nonatomic)UIScrollView *scrollView;
@property (weak, nonatomic)UIScrollView *lrcScrollView;
@property (nonatomic, weak)SSLabel *lrcLabel;// 歌词

@property (nonatomic, weak)UIImageView *singerBgImage;
@property (nonatomic, weak)UILabel *singerLabel;
@property (nonatomic, weak)UILabel *albumLabel;
@property (nonatomic, weak)UILabel *currentTimeLabel;
@property (nonatomic, weak)UIProgressView *progressView;
@property (nonatomic, weak)UILabel *durationLabel;

@property (nonatomic, strong)NSArray *allMusics;
//一首歌的所有行的歌词
@property (nonatomic, strong) NSArray *allLrcLines;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign) NSInteger currentLrcIndex;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController
- (NSArray *)allMusics {
    if (_allMusics == nil) {
        _allMusics = [SSMusicModel mj_objectArrayWithFilename:@"mlist.plist"];
    }
    return _allMusics;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBgImage];
    [self setupBottomButtons];
    [self setupSingerInfo];
    [self setupLrcScrollView];
    [self clickPlay];
    // 锁屏
    [[UIApplication sharedApplication] becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
-(void)dealloc {
    [[UIApplication sharedApplication] resignFirstResponder];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
-(void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(SCREENWIDTH * 2, 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.lrcScrollView.contentSize = CGSizeMake(0, self.allLrcLines.count * kLrcLineHeight);
    [self.lrcScrollView setContentInset:UIEdgeInsetsMake(100, 0, self.lrcScrollView.bounds.size.height * 0.5, 0)];
    self.lrcScrollView.showsVerticalScrollIndicator = NO;
}
- (void)setupBgImage {
    UIImageView *singerBgImage = [[UIImageView alloc] init];
    [self.view addSubview:singerBgImage];
    self.singerBgImage = singerBgImage;
    [singerBgImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(singerBgImage.superview);
    }];
    //UI界面的 玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [singerBgImage addSubview:effectview];
}
- (void)setupBottomButtons {
    UIButton *startOrStopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startOrStopBtn setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
    [startOrStopBtn setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateSelected];
    [startOrStopBtn addTarget:self action:@selector(clickPasue:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startOrStopBtn];
    [startOrStopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(startOrStopBtn.superview);
        make.bottom.equalTo(startOrStopBtn.superview).offset(-40);
    }];
    self.startOrStopBtn = startOrStopBtn;
    //上一曲
    UIButton *lastMusicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lastMusicBtn setImage:[UIImage imageNamed:@"playing_btn_pre_n"] forState:UIControlStateNormal];
    [lastMusicBtn setImage:[UIImage imageNamed:@"playing_btn_pre_h"] forState:UIControlStateHighlighted];
    [lastMusicBtn addTarget:self action:@selector(clickPer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lastMusicBtn];
    [lastMusicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(startOrStopBtn.mas_centerY);
        make.right.equalTo(startOrStopBtn.mas_left).offset(-40);
    }];
    self.lastMusicBtn = lastMusicBtn;
    //下一曲
    UIButton *nextMusicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextMusicBtn setImage:[UIImage imageNamed:@"playing_btn_next_n"] forState:UIControlStateNormal];
    [nextMusicBtn setImage:[UIImage imageNamed:@"playing_btn_next_h"] forState:UIControlStateHighlighted];
    [nextMusicBtn addTarget:self action:@selector(clickNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextMusicBtn];
    [nextMusicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(startOrStopBtn.mas_centerY);
        make.left.equalTo(startOrStopBtn.mas_right).offset(40);
    }];
    self.nextMusicBtn = nextMusicBtn;
}
- (void)setupLrcScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(scrollView.superview);
        make.top.equalTo(scrollView.superview).offset(64);
//        make.bottom.equalTo(self.singerLabel.mas_top).offset(-15);
        make.height.mas_equalTo(290);
    }];
    
    UIScrollView *lrcScrollView = [[UIScrollView alloc] init];
    lrcScrollView.delegate = self;
    [scrollView addSubview:lrcScrollView];
    self.lrcScrollView = lrcScrollView;
    [lrcScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lrcScrollView.superview).offset(100);
        make.left.equalTo(lrcScrollView.superview).offset(SCREENWIDTH);
        make.width.mas_equalTo(SCREENWIDTH);
        make.height.mas_equalTo(180);
    }];
    
    SSLabel *lrcLabel = [[SSLabel alloc] init];
    lrcLabel.textColor = [UIColor whiteColor];
    lrcLabel.font = [UIFont systemFontOfSize:18];
    [lrcLabel sizeToFit];
    [scrollView addSubview:lrcLabel];
    self.lrcLabel = lrcLabel;
    [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(lrcLabel.superview);
        make.bottom.equalTo(scrollView.mas_bottom).offset(-15);
    }];
}
- (void)setupSingerInfo {
    //进度条
    UIProgressView *progressView = [[UIProgressView alloc] init];
    progressView.progressTintColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
    progressView.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(progressView.superview);
        make.size.mas_equalTo(CGSizeMake(SCREENWIDTH - 120, 2));
        make.bottom.equalTo(self.startOrStopBtn.mas_top).offset(-40);
    }];
    
    //当前时间
    UILabel *currentTimeLabel = [[UILabel alloc] init];
    currentTimeLabel.text = @"00:00";
    currentTimeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    currentTimeLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:currentTimeLabel];
    [currentTimeLabel sizeToFit];
    self.currentTimeLabel = currentTimeLabel;
    [currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(progressView.mas_centerY);
        make.left.equalTo(currentTimeLabel.superview).offset(20);
    }];
    //总时长
    UILabel *durationLabel = [[UILabel alloc] init];
    durationLabel.text = @"00:00";
    durationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    durationLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:durationLabel];
    [durationLabel sizeToFit];
    self.durationLabel = durationLabel;
    [durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(progressView.mas_centerY);
        make.left.equalTo(progressView.mas_right).offset(10);
    }];
    
    UILabel *albumLable = [[UILabel alloc] init];
    albumLable.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    albumLable.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:albumLable];
    self.albumLabel = albumLable;
    [albumLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(currentTimeLabel.mas_left);
        make.bottom.equalTo(currentTimeLabel.mas_top).offset(-15);
    }];
    
    UILabel *singerLabel = [[UILabel alloc] init];
    singerLabel.textColor = [UIColor whiteColor];
    singerLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:singerLabel];
    self.singerLabel = singerLabel;
    [singerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(albumLable.mas_left);
        make.bottom.equalTo(albumLable.mas_top).offset(-15);
    }];
}

#pragma mark - Private
//播放或暂停
- (void)clickPasue:(UIButton *)btn {
    if ([[SSMusicTool shareMusicTool] isPlaying]) {
        self.startOrStopBtn.selected = NO;
        [[SSMusicTool shareMusicTool] pause];
        [self.timer invalidate];
        self.timer = nil;
    } else {
        [self clickPlay];
    }
}
//上一曲
- (void)clickPer:(UIButton *)btn {
    self.index = (self.index == 0) ? self.allMusics.count - 1 : self.index - 1;
    [self clickPasue:nil];
    [self clickPlay];
}
//下一曲
- (void)clickNext:(UIButton *)btn {
    self.index = (self.index == self.allMusics.count - 1) ? 0 : self.index + 1;
    [self clickPasue:nil];
    [self clickPlay];
}
//播放
- (void)clickPlay {
    self.startOrStopBtn.selected = YES;
    SSMusicModel *model = self.allMusics[self.index];
    [[SSMusicTool shareMusicTool] playMusicWithFileName:model.mp3];
    self.navigationItem.title = model.name;
    self.singerBgImage.image = [UIImage imageNamed:model.image];
    self.singerLabel.text = model.singer;
    self.albumLabel.text = model.zhuanji;
    self.durationLabel.text = [[SSMusicTool shareMusicTool] durationMusicString];
    self.allLrcLines = [SSLyricTool lyricListWithFileName:model.lrc];
    // 设置全屏歌词
    [self setupLrcLineForScrollView];
    [self addTimer];
}

- (void)addTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(updatepage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}
- (void)updatepage {
    self.lrcLabel.text = @"音乐播放器";
    self.currentTimeLabel.text = [[SSMusicTool shareMusicTool] currentTimeString];
    self.durationLabel.text = [[SSMusicTool shareMusicTool] durationMusicString];
    self.progressView.progress = [[SSMusicTool shareMusicTool] musicProgress];
    NSTimeInterval currentTime = [[SSMusicTool shareMusicTool] currentTime];
    if ([[SSMusicTool shareMusicTool] durationMusic] - currentTime < 0.1) {
        [self clickNext:nil];
    } else {
        for (int i = 0; i < self.allLrcLines.count; i++) {
            SSLyricModel *currentModel = self.allLrcLines[i];
            SSLyricModel *nextModel = nil;
            NSTimeInterval lineEndTime = 0;
            if (i == self.allLrcLines.count - 1) {
                nextModel = self.allLrcLines[i];
                lineEndTime = [[SSMusicTool shareMusicTool] durationMusic];
            } else {
                nextModel = self.allLrcLines[i+ 1];
                lineEndTime = nextModel.time;
            }
            if (currentTime >= currentModel.time && currentTime < lineEndTime) {
                self.lrcLabel.text = currentModel.text;
                self.currentLrcIndex = i;
                self.lrcLabel.progress = (currentTime - currentModel.time) / (lineEndTime - currentModel.time);
                for (id obj in self.lrcScrollView.subviews) {
                    if ([obj isKindOfClass:[SSLabel class]]) {
                        SSLabel *label = (SSLabel *)obj;
                        if (label.currentIndex == i) {
                            label.font = [UIFont systemFontOfSize:18];
                            label.progress = self.lrcLabel.progress;
                        } else {
                            label.font = [UIFont systemFontOfSize:15];
                            label.progress = 0;
                        }
                    }
                }
            }
        }
        //锁屏界面 显示歌曲基本信息    每一行歌词
        //锁屏显示每一行歌词信息 实时更新
        [self setupScreenPage];
        [self.lrcScrollView setContentOffset:CGPointMake(0, -100 + kLrcLineHeight * self.currentLrcIndex)];
    }
}
//歌词
- (void)setupLrcLineForScrollView {
    for (id obj in self.lrcScrollView.subviews) {
        if ([obj isKindOfClass:[SSLabel class]]) {
            [obj removeFromSuperview];
        }
    }
    for (int i = 0; i < self.allLrcLines.count; i++) {
        SSLyricModel *lrcModel = self.allLrcLines[i];
        SSLabel *label = [[SSLabel alloc] init];
        label.currentIndex = i;
        label.text = lrcModel.text;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.lrcScrollView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(label.superview);
            make.top.equalTo(label.superview).offset(kLrcLineHeight * i);
        }];
    }
}
//锁屏界面
- (void)setupScreenPage {
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    SSMusicModel *model = self.allMusics[self.index];
    //专辑
    dict[MPMediaItemPropertyAlbumTitle] = model.zhuanji;
    //演唱者
    dict[MPMediaItemPropertyArtist] = model.singer;
    //名字
    dict[MPMediaItemPropertyTitle] = model.name;
    //当前时长
    dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @([[SSMusicTool shareMusicTool] currentTime]);
    //总时长
    dict[MPMediaItemPropertyPlaybackDuration] = @([[SSMusicTool shareMusicTool] durationMusic]);
    //开启上下文
    CGRect rect = CGRectMake(0, 0, SCREENWIDTH - 20, SCREENWIDTH - 20);
//    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, [UIScreen mainScreen].scale);
    UIImage *sourceImage = [UIImage imageNamed:model.image];
    [sourceImage drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dict[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:newImage];
    
    infoCenter.nowPlayingInfo = dict;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self clickPlay];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self clickPasue:nil];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self clickPer:nil];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self clickNext:nil];
            break;
        default:
            break;
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self clickNext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
