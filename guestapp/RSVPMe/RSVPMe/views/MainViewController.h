//
//  MainViewController.h
//  LexisParty-Guest
//
//  Created by Alex Sue on 2/11/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MainViewController : BaseViewController {
    IBOutlet UIButton* checkInButton;
    
    IBOutlet UITextField* lastNameField;
    IBOutlet UITextField* confirmCode;
    IBOutlet UIButton* loginButton;
    IBOutlet UILabel* attendanceLabel;
    
}

- (void)showOrHideCheckIn;

- (IBAction)doLogin:(id)sender;

- (IBAction)doCheckIn:(id)sender;

@end