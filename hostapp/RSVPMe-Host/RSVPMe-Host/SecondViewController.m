//
//  SecondViewController.m
//  RSVPMe-Host
//
//  Created by Alex Sue on 2/13/15.
//  Copyright (c) 2015 RSVPME. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://rsvpmehack.parseapp.com/index.html"]]];
    webView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
