//
//  MainViewController.m
//  LexisParty-Guest
//
//  Created by Alex Sue on 2/11/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "ParseRest.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "RsvpMeStuff.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self showOrHideCheckIn];
    
    attendanceLabel.text = @"";
    
    [ParseRest callFunctionInBackground:@"attendance" withParameters:nil block:^(NSDictionary* result, NSError* error) {
        attendanceLabel.text = [result objectForKey:@"message"];
    }];
    
    [self updateTitles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showOrHideCheckIn {
    if ([PFUser currentUser]) {
        lastNameField.hidden = YES;
        confirmCode.hidden = YES;
        loginButton.hidden = YES;
        logoutButton.hidden = NO;
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        BOOL isCheckedIn = [defaults boolForKey:CHECKED_IN_STRING];
        
        if (isCheckedIn) {
            checkInButton.hidden = YES;
            checkmark.hidden = NO;
            welcomeLabel.hidden = YES;
        }
        else {
            checkInButton.hidden = NO;
            checkmark.hidden = YES;
            welcomeLabel.hidden = NO;
        }
    }
    else {
        // not logged in
        lastNameField.hidden = NO;
        confirmCode.hidden = NO;
        loginButton.hidden = NO;
        welcomeLabel.hidden = YES;
        
        checkInButton.hidden = YES;
        logoutButton.hidden = YES;
    }
}

- (IBAction)doLogin:(id)sender {
    
    [lastNameField resignFirstResponder];
    [confirmCode resignFirstResponder];
    
    NSString* username = [NSString stringWithFormat:@"%@%@", [confirmCode.text uppercaseString], [lastNameField.text uppercaseString]];
    
    if ([confirmCode.text length] == 0 || [lastNameField.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    NSString* password = @"password";
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser* user, NSError* error) {
        if (user) {
            [self showOrHideCheckIn];
            [self updateTitles];
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem looking you up" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
        }
    }];
}

- (IBAction)doLogout:(id)sender {
    [PFUser logOut];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(NO) forKey:CHECKED_IN_STRING];
    [defaults synchronize];
    
    [self showOrHideCheckIn];
}

- (IBAction)doCheckIn:(id)sender {
    NSDictionary* params = @{@"userId": [PFUser currentUser].objectId};
    
    
    if ( [RsvpMeStuff sharedRsvpMeStuff].isNearEnough ) {
        [ParseRest callFunctionInBackground:@"checkIn" withParameters:params block:^(NSDictionary* result, NSError* error) {
            if (result && !error) {
                int code = [[result objectForKey:@"code"] intValue];
                if (code == 200) {
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:CHECKED_IN_STRING];
                    [defaults synchronize];
                    
                    [self showOrHideCheckIn];
                    
                    // update the attendance
                    [ParseRest callFunctionInBackground:@"attendance" withParameters:nil block:^(NSDictionary* result, NSError* error) {
                        attendanceLabel.text = [result objectForKey:@"message"];
                    }];
                }
                else {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"something failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    
                    [alert show];
                }
            }
            else if (error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }
        }];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Too Far!" message:@"Please get closer to the party reception area" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void)updateTitles {
    if ([PFUser currentUser]) {
        PFUser* user = [PFUser currentUser];
        self.navigationItem.title = @"Check In";
        welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@ %@", user[@"firstName"], user[@"lastName"]];
    }
}

@end