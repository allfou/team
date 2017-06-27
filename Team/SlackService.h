//
//  SlackService.h
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlackService : NSObject

+ (instancetype)sharedManager;

- (NSArray*)getMembersForTeam;

@end
