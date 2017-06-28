//
//  MemberVC.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "MemberVC.h"
#import "SlackService.h"

@interface MemberVC ()

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = self.userName;
    self.realNameLabel.text = self.realName;
    self.titleLabel.text = self.memberTitle;
    
    [[SlackService sharedManager] downloadImageFromUrl:self.pictureUrl withCachedImage:self.cachedThumbnailUrl forUIImageView:self.picture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
