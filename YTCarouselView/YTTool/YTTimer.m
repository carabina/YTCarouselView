//
//  YTTimer.m
//  YTTimer
//
//  Created by songyutao on 2016/11/10.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import "YTTimer.h"

@interface YTTimer ()

@property(nonatomic, assign)BOOL               repeats;
@property(nonatomic, strong)dispatch_source_t  timer;
@property(nonatomic, weak  )id                 target;
@property(nonatomic, assign)SEL                selector;


@end

@implementation YTTimer

- (id)init
{
    self = [super init];
    if (self) {
        self.repeats = YES;
    }
    return self;
}

+ (YTTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    YTTimer *timer = [[YTTimer alloc] init];
    
    [timer setUserInfo:userInfo];
    [timer setTarget:aTarget];
    [timer setSelector:aSelector];
    [timer setInterval:ti];
    [timer setRepeats:yesOrNo];
    [timer runSelector:nil];
    
    return timer;
}

+ (nullable YTTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void (^ _Nullable)(YTTimer * _Nullable timer))block
{
    YTTimer *timer = [[YTTimer alloc] init];
    [timer setInterval:ti];
    [timer setRepeats:yesOrNo];
    [timer runSelector:block];
    
    return timer;
}

- (void)runSelector:(void (^)(YTTimer *timer))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), self.interval * NSEC_PER_SEC, self.interval);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (block)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(self);
            });
        }
        else
        {
            [self.target performSelectorOnMainThread:self.selector withObject:self.userInfo waitUntilDone:NO];
        }
        
        if (!self.repeats)
        {
            [self invalidate];
        }

    });
    
    dispatch_source_set_cancel_handler(self.timer, ^{
        self.timer = nil;
    });
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_resume(self.timer);
    });
    
}

- (void)invalidate
{
    self.repeats = NO;
    
    dispatch_source_cancel(self.timer);
}

@end
