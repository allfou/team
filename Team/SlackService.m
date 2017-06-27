//
//  SlackService.m
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "SlackService.h"
#import "AFURLSessionManager.h"

@interface SlackService ()

@property (nonatomic) NSString *slackApiUrl;
@property (nonatomic) NSString *slackToken;
@property (nonatomic) NSMutableArray *members;

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
    }
    
    return self;
}

- (NSArray*)getMembersForTeam {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSDictionary *parameters = @{@"token": self.slackToken};
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:self.slackApiUrl parameters:parameters error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
    
    return nil;
}

@end
