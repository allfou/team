//
//  SettingsVC.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()

@property (weak, nonatomic) IBOutlet UILabel *versionDetailLabel;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init App Version Details
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    self.versionDetailLabel.text = [infoDict objectForKey:@"CFBundleShortVersionString"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove inset separator
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:17.0f];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 15, self.view.frame.size.width, 40);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:13.0f];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 47;
}

@end
