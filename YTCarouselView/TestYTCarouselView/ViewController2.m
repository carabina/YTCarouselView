//
//  ViewController.m
//  TestYTCarouselView
//
//  Created by songyutao on 2016/11/21.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import "ViewController2.h"
#import "YTCarouselView.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)dealloc
{
    NSLog(@"%@", self.description);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YTCarouselView *carouselView = [[YTCarouselView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 180)];
    carouselView.delegate = (id<YTCarouselViewDelegate>)self;
    [carouselView reloadData];
    [self.view addSubview:carouselView];
}


#pragma - mark - YTCarouselViewDelegate
- (NSUInteger)numberOfLoopImageView:(YTCarouselView *)loopImageView
{
    return 4;
}

- (UIView *)loopImageView:(YTCarouselView *)loopImageView viewForIndex:(NSUInteger)index
{
    NSUInteger count = [self numberOfLoopImageView:loopImageView];
    NSInteger step = 255/count;
    
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loopImageView.bounds.size.width, loopImageView.bounds.size.height)];
    view.backgroundColor = [UIColor colorWithRed:step/255.0 green:index*index/255.0 blue:index*step/255.0 alpha:1];
    view.text = [NSString stringWithString:[@(index) stringValue]];
    view.textAlignment = NSTextAlignmentCenter;
    return view;
}

- (void)didSelected:(YTCarouselView *)loopImageView forIndex:(NSUInteger)index
{
    NSLog(@"%ld", index);
}

@end
