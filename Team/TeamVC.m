//
//  TeamVC.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <ISMessages/ISMessages.h>
#import "TeamVC.h"
#import "SlackService.h"
#import "AppDelegate.h"
#import "MemberCell.h"
#import "Members+CoreDataClass.h"
#import "Profiles+CoreDataClass.h"
#import "MemberVC.h"
#import "Theme.h"

@interface TeamVC ()

@property UIImageView *navLogo;
@property (nonatomic) NSArray *members;
@property BOOL isRefreshing;

@end

@implementation TeamVC

static NSString * const reuseIdentifier = @"memberCellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Custom MemberCell
    UINib *memberCellNib = [UINib nibWithNibName:@"MemberCell" bundle:nil];
    [self.tableView registerNib:memberCellNib forCellReuseIdentifier:reuseIdentifier];
    
    // Init Refresh Controller
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = refreshControllerColor;
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    self.isRefreshing = NO;
    
    // Init Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserMsg:) name:@"displayUserMsgMessageEvent" object:nil];
    
    // Init Navigation Bar (Logo)
    self.navLogo = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"nav_logo.png"]];
    self.navigationItem.titleView = self.navLogo;
    
    // Init Table View
    self.tableView.separatorColor = [UIColor clearColor];
    
    // Init Data
    [self getMembersList];
    
    // Init Members data from CoreData
    [self initializeFetchedResultsController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Bug with refreshcontrol being position above cells
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
}

// ***************************************************************************************************

#pragma mark Notifications

- (void)displayUserMsg:(NSNotification*)notification {
    NSString *msg = [notification object];
    
    [ISMessages showCardAlertWithTitle:@"Info"
                               message:msg
                              duration:6.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeInfo
                         alertPosition:ISAlertPositionTop
                               didHide:^(BOOL finished) {
                                   NSLog(@"Alert did hide.");
                               }];
}

// ***************************************************************************************************

#pragma mark - Refresh Control

- (void)pullToRefresh {
    // Improve refresh UI effect
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isRefreshing = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self containingScrollViewDidEndDragging:scrollView];
    
    if (self.isRefreshing) {
        [self getMembersList];
    }
}

- (void)containingScrollViewDidEndDragging:(UIScrollView *)containingScrollView {
    CGFloat minOffsetToTriggerRefresh = 130.0f;
    if (!self.isRefreshing && (containingScrollView.contentOffset.y <= -minOffsetToTriggerRefresh)) {
        self.isRefreshing = YES;
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self containingScrollViewDidEndDragging:scrollView];
}

// ***************************************************************************************************

#pragma mark Data

- (void)getMembersList {
    [[SlackService sharedManager]getMembersForTeam];
}

// ***************************************************************************************************

#pragma mark CollectionView (DataSource & Delegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Update cell with Member and Profile data
    Members *member = (Members*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    Profiles *profile = (Profiles*)[member valueForKey:@"hasProfile"];
    
    // Picture (default to 'member.png' if null)
    [[SlackService sharedManager] downloadImageFromUrl:[[profile valueForKey:@"thumbnailUrl"] description]
                                       withCachedImage:[[profile valueForKey:@"thumbnailCachedUrl"] description]
                                        forUIImageView:cell.photo];
    
    // Username (default to 'Anonymous' if null)
    if ([[[member valueForKey:@"name"] description] isEqualToString:@"(null)"]) {
        cell.username.text = @"Anonymous";
    } else {
        cell.username.text = [[member valueForKey:@"name"] description];
    }
    
    // Title (default to 'No Title' if null)
    if ([[[profile valueForKey:@"title"] description] isEqualToString:@"(null)"]) {
        cell.title.text = @"No Title";
    } else {
        cell.title.text = [[profile valueForKey:@"title"] description];
    }
    
    // Set all the invisible attributes used for Member Detail view
    cell.pictureUrl = [[profile valueForKey:@"pictureUrl"] description];
    cell.cachedThumbnailUrl = [[profile valueForKey:@"thumbnailCachedUrl"] description];
    cell.realName = [[member valueForKey:@"realName"] description];
    cell.email = [[profile valueForKey:@"email"] description];
    cell.phone = [[profile valueForKey:@"phone"] description];
    cell.skype = [[profile valueForKey:@"skype"] description];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *showMemberDetailsSegue = @"showMemberDetailsSegue";
    [self performSegueWithIdentifier:showMemberDetailsSegue sender:self];
}

// ***************************************************************************************************

#pragma mark - Navigation and Segues

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MemberCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if ([segue.destinationViewController isKindOfClass:[MemberVC class]]) {
        MemberVC *vc = segue.destinationViewController;
        vc.pictureUrl = cell.pictureUrl;
        vc.cachedThumbnailUrl = cell.cachedThumbnailUrl;
        vc.userName = cell.username.text;
        vc.memberTitle = cell.title.text;
        vc.realName = cell.realName;
        vc.email = cell.email;
        vc.phone = cell.phone;
        vc.skype = cell.skype;
    }
}

// ***************************************************************************************************

#pragma mark - NSFetchedResultsController (Delegate)

- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Members"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[nameSort]];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appdelegate.persistentContainer.viewContext;
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:moc
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

// Communicate data uptades to the Table View with the following delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

@end
