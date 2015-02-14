//
//  MenuViewController.m
//  LexisParty-Guest
//
//  Created by Alex Sue on 2/11/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import "MenuViewController.h"
#import "ECSlidingViewController.h"
#import "Constants.h"

#define MENU_WIDTH              200 // how far the menu extends out
#define MENU_HEADER_HEIGHT      200 // the height of the table header for the section


@interface MenuViewController () {
    NSDictionary* menuToIdentifier;
}

@end

@implementation MenuViewController

@synthesize menu;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.menu = [NSArray arrayWithObjects:@"Check In", @"Photo Stream", nil];
    menuToIdentifier = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"checkIn", @"photos", nil] forKeys:self.menu];
    
    
    [self.slidingViewController setAnchorRightRevealAmount:MENU_WIDTH];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    self.tableView.layer.backgroundColor = [UIColor colorWithRed:0.971515f green:0.971515f blue:0.971515f alpha:1].CGColor;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.tableView.scrollsToTop = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    UILabel* lbl = (UILabel*)[cell.contentView viewWithTag:2];
    lbl.text = [NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate method(s)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // display the relevant controller depending on the menu selection
    NSString* identifier = [menuToIdentifier objectForKey:[self.menu objectAtIndex:indexPath.row]];
    
    // NSString* menuItem = [NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]];
    // NSString* identifier = [menu2 objectForKey:menuItem];
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // return MENU_HEADER_HEIGHT;
    return 64.0f;   // status bar height + nav bar height
}

@end