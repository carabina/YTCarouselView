//
//  ViewController.m
//  TestYTCarouselView
//
//  Created by songyutao on 2016/11/21.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:0];
    [button setBackgroundColor:[UIColor redColor]];
    [button setFrame:CGRectMake(100, 100, 100, 40)];
    [button setTitle:@"carousel" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goCarousel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goCarousel
{
    ViewController2 *controller = [[ViewController2 alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
