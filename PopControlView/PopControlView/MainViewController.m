//
//  ViewController.m
//  PopControlView
//
//  Created by BroadLink on 2017/6/26.
//  Copyright © 2017年 方琼蔚. All rights reserved.
//

#import "MainViewController.h"
#import "BLPopController.h"

@interface MainViewController (){
    UIImageView *imgView;
}
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    imgView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 100, 50, 50)];
    imgView.image = [UIImage imageNamed:@"image"];
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewTap)];
    [imgView addGestureRecognizer:tap];

    [self.view addSubview:imgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(imageViewShow)
               name:@"viewDismiss"
             object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)imageViewShow
{
    imgView.alpha = 1;
}

- (void)onImageViewTap
{
    BLPopController *vc = [BLPopController popControllerWithCenterImage:[imgView image] originFrame:[imgView.superview convertRect:imgView.frame toView:nil]];
    [vc addAction:[BLPopAction actionWithTitle:@"aaa" withImageName:@"imga" handler:^(BLPopAction * _Nonnull action){
        NSLog(@"aaa");
    }]];
    [vc addAction:[BLPopAction actionWithTitle:@"bbb" withImageName:@"imgb" handler:^(BLPopAction * _Nonnull action){
        NSLog(@"bbb");
    }]];
    [vc addAction:[BLPopAction actionWithTitle:@"ccc" withImageName:@"imgc" handler:^(BLPopAction * _Nonnull action){
        NSLog(@"ccc");
    }]];
    [vc addAction:[BLPopAction actionWithTitle:@"ddd" withImageName:@"imgd" handler:^(BLPopAction * _Nonnull action){
         NSLog(@"ddd");
    }]];
    imgView.alpha = 0;
    [self presentViewController:vc animated:YES completion:^{
    }];
}

@end

