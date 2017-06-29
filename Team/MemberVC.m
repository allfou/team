//
//  MemberVC.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <ISMessages/ISMessages.h>
#import "MemberVC.h"
#import "SlackService.h"

@interface MemberVC ()

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *skypeButton;

@end

@implementation MemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = self.userName;
    self.realNameLabel.text = self.realName;
    self.titleLabel.text = self.memberTitle;
    
    // Picture
    [[SlackService sharedManager] downloadImageFromUrl:self.pictureUrl withCachedImage:self.cachedThumbnailUrl forUIImageView:self.picture];
    
    // Email
    if ((self.email) && !([self.email isEqualToString:@""])) {
        [self.emailButton setImage:[UIImage imageNamed:@"email_active"] forState:UIControlStateNormal];
        [self.emailButton setUserInteractionEnabled:YES];
    } else {
        [self.emailButton setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
        [self.emailButton setUserInteractionEnabled:NO];
    }
    
    // Phone
    if ((self.phone) && !([self.phone isEqualToString:@""])) {
        [self.phoneButton setImage:[UIImage imageNamed:@"phone_active"] forState:UIControlStateNormal];
        [self.phoneButton setUserInteractionEnabled:YES];
    } else {
        [self.phoneButton setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        [self.phoneButton setUserInteractionEnabled:NO];
    }
    
    // Skype
    if ((self.skype) && !([self.skype isEqualToString:@""])) {
        [self.skypeButton setImage:[UIImage imageNamed:@"skype_active"] forState:UIControlStateNormal];
        [self.skypeButton setUserInteractionEnabled:YES];
    } else {
        [self.skypeButton setImage:[UIImage imageNamed:@"skype"] forState:UIControlStateNormal];
        [self.skypeButton setUserInteractionEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// For now, just display a message when user press any contact button...

- (IBAction)displayEmail:(id)sender {
    [ISMessages showCardAlertWithTitle:@"Email:"
                               message:self.email
                              duration:2.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeSuccess
                         alertPosition:ISAlertPositionBottom
                               didHide:^(BOOL finished) {
                                   // NSLog(@"action");
                               }];
}

- (IBAction)displayPhone:(id)sender {
    [ISMessages showCardAlertWithTitle:@"Phone:"
                               message:self.phone
                              duration:2.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeSuccess
                         alertPosition:ISAlertPositionBottom
                               didHide:^(BOOL finished) {
                                   // NSLog(@"action");
                               }];
}

- (IBAction)displaySkype:(id)sender {
    [ISMessages showCardAlertWithTitle:@"Skype ID:"
                               message:self.skype
                              duration:2.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeSuccess
                         alertPosition:ISAlertPositionBottom
                               didHide:^(BOOL finished) {
                                   // NSLog(@"action");
                               }];
}

@end
