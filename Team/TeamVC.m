//
//  TeamVC.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "TeamVC.h"
#import "SlackService.h"

@interface TeamVC ()

@property (nonatomic) NSArray *members;

@property UIImageView *navLogo;

@end

@implementation TeamVC

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMembersList:) name:@"refreshMembersListMessageEvent" object:nil];
    
    // Init Navigation Bar (Logo)
    self.navLogo = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"nav_logo.png"]];
    self.navigationController.navigationItem.titleView = self.navLogo;
    
    // Init Member Data
    [self getMembersList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// ************************************************************************************************************

#pragma mark Notifications

- (void)refreshMembersList:(NSNotification*)notification {
    self.members = [notification object];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

// ************************************************************************************************************

#pragma mark Data

- (void)getMembersList {
    [[SlackService sharedManager]getMembersForTeam];
}


// ************************************************************************************************************

#pragma mark CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.members count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

@end
