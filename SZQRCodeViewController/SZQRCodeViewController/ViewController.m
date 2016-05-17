//
//  ViewController.m
//  SZQRCodeViewController
//
//  Created by Stephen Zhuang on 16/5/17.
//  Copyright © 2016年 StephenZhuang. All rights reserved.
//

#import "ViewController.h"
#import "SZQRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonAction:(id)sender
{
    SZQRCodeViewController *vc = [[SZQRCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
