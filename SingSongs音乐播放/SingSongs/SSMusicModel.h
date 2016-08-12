//
//  SSMusicModel.h
//  SingSongs
//
//  Created by Ethank on 16/4/26.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSMusicModel : NSObject
@property (nonatomic, copy)NSString *image;
@property (nonatomic, copy)NSString *lrc;
@property (nonatomic, copy)NSString *mp3;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *singer;
@property (nonatomic, copy)NSString *zhuanji;
@property (nonatomic, strong)NSNumber *type;
@end
