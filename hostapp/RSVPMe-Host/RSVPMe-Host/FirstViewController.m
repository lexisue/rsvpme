//
//  FirstViewController.m
//  RSVPMe-Host
//
//  Created by Alex Sue on 2/13/15.
//  Copyright (c) 2015 RSVPME. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://rsvpmehack.parseapp.com/checkedIn.html"]]];
    webView.delegate = self;

    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate transmitBeacon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
