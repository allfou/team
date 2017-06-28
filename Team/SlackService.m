//
//  SlackService.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//
//
//
//  Use Cases handled by getMembersForTeam method:
//
//  1. Initial launch of the App: CoreData is empty, we pull data from remote server then populate CoreData
//  2. User pulls down to refresh: We also pull data from remote server then update CoreData
//  3. Airplane Mode or App termination: If CoreData is not empty, then display local data to the user
//  4. No internet connection during Initial Launch: Display a relevent message to the User
//
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

- (NSArray*)getMembersForTeam {
    // Display Network Activity Monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSDictionary *parameters = @{@"token": self.slackToken};
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:self.slackApiUrl parameters:parameters error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        // Stop network activity monitor
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // If error then display a relevant error message to the user
        if (error) {
            NSLog(@"Error: %@", error);
            
            NSString *userErrorMessage = @"";
            
            // No internet connection
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == -1009) {
                userErrorMessage = @"You may want to check your Internet connection. It appears to be offline.";
            }
            // Add more error cases here...
        }
        
        // If result is empty then display a relevant info message to the user
        else if ([responseObject[@"members"] count] == 0) {
            NSString *userInfoMessage = @"No members found for the team.";
            
            // Else map JSON response into CoreData objects that will be displayed to the user
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
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"email"]] forKey:@"email"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"title"]] forKey:@"title"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"image_48"]] forKey:@"picture"];
                    [self storeMemberPictureFromUrl:profileDict[@"image_48"] inProfile:profile];
                    [member setValue:profile forKey:@"hasProfile"];
                    
                    // Else update existing Member and Profile entries
                } else {
                    // We assume there will only be one member entry for a given memberId
                    // Also, we don't need to update the memberId since it should be unchanged
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"real_name"]] forKey:@"realName"];
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"name"]] forKey:@"name"];
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"team_id"]] forKey:@"teamId"];
                    
                    // Update Member Profile entry
                    Profiles *profile = [[Profiles alloc] initWithEntity:self.profileEntity insertIntoManagedObjectContext:self.manageContext];
                    NSDictionary *profileDict = memberDict[@"profile"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"email"]] forKey:@"email"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"title"]] forKey:@"title"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"image_48"]] forKey:@"picture"];
                    [self storeMemberPictureFromUrl:profileDict[@"image_48"] inProfile:profile];
                    [fetchedObjects[0] setValue:profile forKey:@"hasProfile"];
                }
            }
        }
    }];
    [dataTask resume];
    
    return nil;
}

- (void)storeMemberPictureFromUrl:(NSString*)imageUrl inProfile:(Profiles*)profile {
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLSessionDataTask *downloadDataTask = [[NSURLSession sharedSession]
              dataTaskWithURL:url
              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                  if (error) {
                      NSLog(@"%@", [error localizedDescription]);
                  } else {
                      
                      // We store the image locally in documentsDirectory then we store the path in CoreData
                      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                      NSString *documentsDirectory = [paths objectAtIndex:0];
                      NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[imageUrl lastPathComponent]];
                      if (![data writeToFile:imagePath atomically:NO]) {
                          NSLog(@"Failed to cache image data to disk");
                      }
                      else {
                        [profile setValue:imagePath forKey:@"pictureCached"];
                      }
                  }
              }];
    
    [downloadDataTask resume];
}

// ***************************************************************************************************

#pragma mark - Public Methods

- (void)downloadImageFromUrl:(NSString*)imageUrl forUIImageView:(UIImageView*)imageView {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        UIImage *placeholderImage = [UIImage imageNamed:@"team"];
        __weak UIImageView *weakImgView = imageView;
    
        // Use AFNetworking as much as possible! If no network connection then load cached images...
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
                                        NSLog(@"Could not find remote image");
                                        
                                        // Look in the cache if the photo was previously downloaded and load it
                                        NSData *imgData = [NSData dataWithContentsOfFile:imageUrl];
                                        UIImage *photo = [[UIImage alloc] initWithData:imgData];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            weakImgView.alpha = 0.0f;
                                            weakImgView.image = photo;
                                            [UIView animateWithDuration:0.5f animations:^{
                                                weakImgView.alpha = 1.0f;
                                                [weakImgView setNeedsLayout];
                                            }];
                                        });
                                    }];
}

@end
