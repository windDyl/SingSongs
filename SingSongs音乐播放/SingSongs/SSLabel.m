//
//  SSLabel.m
//  SingSongs
//
//  Created by Ethank on 16/4/26.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import "SSLabel.h"

@implementation SSLabel

-(void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [[UIColor greenColor]setFill];
    UIRectFillUsingBlendMode(CGRectMake(0, 0, _progress * rect.size.width, rect.size.height), kCGBlendModeSourceIn);
}


@end
