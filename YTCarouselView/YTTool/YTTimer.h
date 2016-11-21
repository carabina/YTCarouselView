//
//  YTTimer.h
//  YTTimer
//
//  Created by songyutao on 2016/11/10.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTTimer : NSObject

@property(assign)NSTimeInterval                         interval;
@property(nullable, strong)id                           userInfo;

/*
 *
 *  repeats:    如果是YES，需要手动调用invalidate来停止，如果是NO，执行一次之后自动调用invalidate
 *
 */
+ (nullable YTTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

/*
 *
 *  repeats:    如果是YES，需要手动调用invalidate来停止，如果是NO，执行一次之后自动调用invalidate
 *  block:      调用者在block块中使用弱引用，避免循环引用
 *
 */
+ (nullable YTTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void (^ _Nullable)(YTTimer * _Nullable timer))block;

- (void)invalidate;

@end
