//
//  SSLyricTool.m
//  SingSongs
//
//  Created by Ethank on 16/4/27.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import "SSLyricTool.h"
#import "SSLyricModel.h"

@implementation SSLyricTool
+ (NSArray *)lyricListWithFileName:(NSString *)fileName {
    NSMutableArray *resArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *originString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [originString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\[[0-9][0-9]:[0-9][0-9]\\.[0-9][0-9]\\]" options:0 error:nil];
        NSArray *arr = [regular matchesInString:line options:0 range:NSMakeRange(0, line.length)];
        //正文
        NSTextCheckingResult *lastResult = [arr lastObject];
        NSString *strText = [line substringFromIndex:lastResult.range.location + lastResult.range.length];
        for (NSTextCheckingResult *result in arr) {
            //时间文本
            NSString *strTime = [line substringWithRange:result.range];
            SSLyricModel *model = [[SSLyricModel alloc] init];
            model.text = strText;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"[mm:ss.SS]";
            NSDate *dateModel = [formatter dateFromString:strTime];
            NSDate *dateZero = [formatter dateFromString:@"[00:00.00]"];
            model.time = [dateModel timeIntervalSinceDate:dateZero];
            [resArray addObject:model];
        }
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    return [resArray sortedArrayUsingDescriptors:@[sort]];
}
@end
