//
//  SlackService.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//
//
//
//  Use Cases handled by the Slack Service:
//
//  1. Initial launch of the App: CoreData is empty, then pull members data from remote server and populate CoreData
//  2. User pulls down to refresh: Same as 1. pull members data from remote server then update CoreData
//  3. Airplane Mode or App termination: If CoreData is not empty, then display local data to the user
//  4. No internet connection during Initial Launch: Display a relevent message to the User
//  5. Invalid Slack API token or no members found for given team: Display a relevent message to the User
//

#import "SlackService.h"
#import "AFURLSessionManager.h"
#import "Members+CoreDataClass.h"
#import "Profiles+CoreDataClass.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"

@interface SlackService ()

@property (nonatomic) NSString *slackApiUrl;
@property (nonatomic) NSString *slackToken;
@property (nonatomic) NSMutableArray *members;
@property (nonatomic) NSManagedObjectContext *manageContext;
@property (nonatomic) NSEntityDescription *memberEntity;
@property (nonatomic) NSEntityDescription *profileEntity;

@end

@implementation SlackService

+ (instancetype)sharedManager {
    static SlackService* sharedManager;
    if(!sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[self alloc] init];
        });
    }
    
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    
    if(self) {
        // Init Slack API Credentials
        self.slackApiUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"slackApiUrl"];
        self.slackToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"slackToken"];
        
        // Init Manage Context for CoreData operations
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.manageContext = appdelegate.persistentContainer.viewContext;
        
        // Init CoreData entities
        self.memberEntity = [NSEntityDescription entityForName:@"Members" inManagedObjectContext:self.manageContext];
        self.profileEntity = [NSEntityDescription entityForName:@"Profiles" inManagedObjectContext:self.manageContext];
    }
    
    return self;
}

// Get all members of a team (using Slack API Token), then insert or update the data in CoreData entities
- (void)getMembersForTeam {
    // Display Network Activity Monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Prepare request to get members list using Slack API Endpoint
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSDictionary *parameters = @{@"token": self.slackToken};
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:self.slackApiUrl parameters:parameters error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        // Stop network activity monitor
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // If error then display a relevant error message to the user
        if (error) {
            // No internet connection
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == -1009) {
                NSString *userErrorMessage = @"You may want to check your Internet connection. It appears to be offline (Scroll down to retry)";
                
                // Let the Controller display an alert message to the User by sending out a notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"displayUserMsgMessageEvent" object:userErrorMessage];
            }
            // Add more error cases here...
        }
        
        // If result is empty then display a relevant info message to the user
        else if ([responseObject[@"members"] count] == 0) {
            NSString *userInfoMessage = @"No members found for this team.";
            
            // Let the Controller display an alert message to the User
            [[NSNotificationCenter defaultCenter] postNotificationName:@"displayUserMsgMessageEvent" object:userInfoMessage];
            
        // Else map JSON response into CoreData entities
        } else {
            for (NSDictionary *memberDict in responseObject[@"members"]) {
                
                // Check if Member already exist in CoreData
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Members"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId == %@", [NSString stringWithFormat:@"%@", memberDict[@"id"]]];
                NSError *error;
                [fetchRequest setPredicate:predicate];
                NSArray *fetchedObjects = [self.manageContext executeFetchRequest:fetchRequest error:&error];
                
                // If Member doesn't exist in CoreData then create it
                if ([fetchedObjects count] == 0) {
                    
                    // Create Member entry
                    Members *member = [[Members alloc] initWithEntity:self.memberEntity insertIntoManagedObjectContext:self.manageContext];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"real_name"]] forKey:@"realName"];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"id"]] forKey:@"memberId"];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"name"]] forKey:@"name"];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"team_id"]] forKey:@"teamId"];
                    
                    // Create Profile entry
                    Profiles *profile = [[Profiles alloc] initWithEntity:self.profileEntity insertIntoManagedObjectContext:self.manageContext];
                    NSDictionary *profileDict = memberDict[@"profile"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"title"]] forKey:@"title"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"email"]] forKey:@"email"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"phone"]] forKey:@"phone"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"skype"]] forKey:@"skype"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"image_72"]] forKey:@"thumbnailUrl"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"image_original"]] forKey:@"pictureUrl"];
                    [self saveThumbnailFromUrl:profileDict[@"image_72"] forMember:member inProfile:profile];
                    
                // Else update existing Member and Profile entries
                } else {
                    // We assume there will be only one member entry for a given memberId
                    // Also, we don't need to update the memberId since it shouldn't change
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"real_name"]] forKey:@"realName"];
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"name"]] forKey:@"name"];
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"team_id"]] forKey:@"teamId"];
                    
                    // Update Member Profile entry
                    Profiles *profile = [[Profiles alloc] initWithEntity:self.profileEntity insertIntoManagedObjectContext:self.manageContext];
                    NSDictionary *profileDict = memberDict[@"profile"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"title"]] forKey:@"title"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"email"]] forKey:@"email"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"phone"]] forKey:@"phone"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"skype"]] forKey:@"skype"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"image_72"]] forKey:@"thumbnailUrl"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"image_original"]] forKey:@"pictureUrl"];
                    [self saveThumbnailFromUrl:profileDict[@"image_72"] forMember:fetchedObjects[0] inProfile:profile];
                }
            }
        }
    }];
    [dataTask resume];
}

// Stores a member thumbnail locally in documentsDirectory and store the file path in CoreData
// The app uses the cached thumbnail to handle offline modes such as no network connection, airplane mode, etc.
- (void)saveThumbnailFromUrl:(NSString*)imageUrl forMember:(Members*)member inProfile:(Profiles*)profile {
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLSessionDataTask *downloadDataTask = [[NSURLSession sharedSession]
              dataTaskWithURL:url
              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                  if (error) {
                      NSLog(@"%@", [error localizedDescription]);
                  } else {
                      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                      NSString *documentsDirectory = [paths objectAtIndex:0];
                      NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[imageUrl lastPathComponent]];
                      if (![data writeToFile:imagePath atomically:NO]) {
                          NSLog(@"Failed to cache image data to disk");
                      }
                      else {
                        [profile setValue:imagePath forKey:@"thumbnailCachedUrl"];
                          
                        // Save updated profile for member
                        [member setValue:profile forKey:@"hasProfile"];
                      }
                  }
              }];
    
    [downloadDataTask resume];
}

// ***************************************************************************************************

#pragma mark - Public Methods

- (void)downloadImageFromUrl:(NSString*)imageUrl withCachedImage:(NSString*)cachedImageUrl forUIImageView:(UIImageView*)imageView {
    __weak UIImageView *weakImgView = imageView;
    
    // If no image url is provided then load default image
    if ((!imageUrl) || [imageUrl isEqualToString:@"(null)"]) {
        [self loadDefaultImage:cachedImageUrl forUIImageView:weakImgView];
        
    // Else, use AFNetworking to download remote image
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        UIImage *placeholderImage = [UIImage imageNamed:@"member"];
        
        [weakImgView setImageWithURLRequest:request
                           placeholderImage:placeholderImage
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {                                                                                
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            weakImgView.alpha = 0.0f;
                                            weakImgView.image = image;
                                            [UIView animateWithDuration:0.5f animations:^{
                                                weakImgView.alpha = 1.0f;
                                                [weakImgView setNeedsLayout];
                                            }];
                                        });
                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        
                                        // If no network connection failed or any other error, load detault image
                                        [self loadDefaultImage:cachedImageUrl forUIImageView:weakImgView];
                                    }];
    }
}

- (void)loadDefaultImage:(NSString*)cachedImageUrl forUIImageView:(UIImageView*)imageView {
    // Use the cached thumbnail if it exist locally...
    NSData *imgData = [NSData dataWithContentsOfFile:cachedImageUrl];
    if (imgData) {
        UIImage *photo = [[UIImage alloc] initWithData:imgData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.alpha = 0.0f;
            imageView.image = photo;
            [UIView animateWithDuration:0.5f animations:^{
                imageView.alpha = 1.0f;
                [imageView setNeedsLayout];
            }];
        });
        
    // If no local thumbnail then default to member.png photo...
    } else {        
        imageView.image = [UIImage imageNamed:@"member"];
    }
}

@end
