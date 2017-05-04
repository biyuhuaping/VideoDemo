//
//  ViewController.m
//  VideoDemo
//
//  Created by biyuhuaping on 2017/5/3.
//  Copyright © 2017年 biyuhuaping. All rights reserved.
//

#import "ViewController.h"
#import "LZNewPromotionVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"VideoDemo";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)VideoDemo:(id)sender {
    LZNewPromotionVC *view = [[LZNewPromotionVC alloc]initWithNibName:@"LZNewPromotionVC" bundle:nil];
    [self.navigationController pushViewController:view animated:YES];
}

@end
