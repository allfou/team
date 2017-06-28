//
//  SlackService.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "SlackService.h"
#import "AFURLSessionManager.h"
#import "Members+CoreDataClass.h"
#import "Profiles+CoreDataClass.h"
#import "AppDelegate.h"

@interface SlackService ()

@property (nonatomic) NSString *slackApiUrl;
@property (nonatomic) NSString *slackToken;
@property (nonatomic) NSMutableArray *members;
@property (nonatomic) NSManagedObjectContext *moc;

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
        self.moc = appdelegate.persistentContainer.viewContext;
    }
    
    return self;
}

/***
*
*  Use Cases handled by getMembersForTeam method:
*
*  1. Initial launch of the App: CoreData is empty, we pull data from remote server then populate CoreData
*  2. User pulls down to refresh: We also pull data from remote server then update CoreData
*  3. Airplane Mode or App termination: If CoreData is not empty, then display local data to the user
*  4. No internet connection during Initial Launch: Display a relevent message to the User
*
****/

- (NSArray*)getMembersForTeam {
    // Display Network Activity Monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //NSDictionary *parameters = @{@"token": self.slackToken};
    NSDictionary *parameters = @{@"token": @"hello"};
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
                AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSManagedObjectContext *moc = appdelegate.persistentContainer.viewContext;
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Members"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId == %@", [NSString stringWithFormat:@"%@", memberDict[@"id"]]];
                NSError *error;
                [fetchRequest setPredicate:predicate];
                NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
                
                NSEntityDescription *profileEntity = [NSEntityDescription entityForName:@"Profiles" inManagedObjectContext:self.moc];
                Profiles *profile = [[Profiles alloc] initWithEntity:profileEntity insertIntoManagedObjectContext:self.moc];
                
                // If Member doesn't exist in CoreData then create it
                if ([fetchedObjects count] == 0) {
                    NSEntityDescription *memberEntity = [NSEntityDescription entityForName:@"Members" inManagedObjectContext:self.moc];
                    Members *member = [[Members alloc] initWithEntity:memberEntity insertIntoManagedObjectContext:self.moc];
                    
                    // Create Member entry
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"real_name"]] forKey:@"realName"];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"id"]] forKey:@"memberId"];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"name"]] forKey:@"name"];
                    [member setValue:[NSString stringWithFormat:@"%@", memberDict[@"team_id"]] forKey:@"teamId"];
                    
                    // Create Profile entry
                    NSDictionary *profileDict = memberDict[@"profile"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"email"]] forKey:@"email"];
                    [member setValue:profile forKey:@"hasProfile"];
                
                // Else update existing Member and Profile entries
                } else {
                    // We assume there will only be one member entry for a given memberId
                    // Also, we don't need to update the memberId since it should be unchanged
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"real_name"]] forKey:@"realName"];
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"name"]] forKey:@"name"];
                    [fetchedObjects[0] setValue:[NSString stringWithFormat:@"%@", memberDict[@"team_id"]] forKey:@"teamId"];
                    
                    NSDictionary *profileDict = memberDict[@"profile"];
                    [profile setValue:[NSString stringWithFormat:@"%@", profileDict[@"email"]] forKey:@"email"];
                    [fetchedObjects[0] setValue:profile forKey:@"hasProfile"];
                }                
            }
        }
    }];
    [dataTask resume];
    
    return nil;
}

@end
