//
//  ViewController.m
//  RoundLayer
//
//  Created by L on 2017/8/14.
//  Copyright © 2017年 L. All rights reserved.
//

#import "ViewController.h"
#import "SoundAnimationView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SoundAnimationView *view = [[SoundAnimationView alloc]init];
    view.frame = self.view.frame;
    [self.view addSubview:view];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
