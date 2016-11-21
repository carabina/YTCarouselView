//
//  YTCarouselView.h
//  YTCarouselView
//
//  Created by songyutao on 2016/11/21.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTCarouselView;

@protocol YTCarouselViewDelegate <NSObject>

- (NSUInteger)numberOfLoopImageView:(YTCarouselView *)carouselView;
- (UIView *)loopImageView:(YTCarouselView *)carouselView viewForIndex:(NSUInteger)index;
- (void)didSelected:(YTCarouselView *)carouselView forIndex:(NSUInteger)index;

@end

@interface YTCarouselView : UIView

@property(nonatomic, assign)NSTimeInterval                  interval;
@property(nonatomic, weak  )id<YTCarouselViewDelegate>      delegate;

- (void)reloadData;

@end
