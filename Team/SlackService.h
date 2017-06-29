//
//  SlackService.h
//  Team
//
//  Created by Fouad Allaoui on 6/26/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlackService : NSObject

+ (instancetype)sharedManager;

- (void)getMembersForTeam;

- (void)downloadImageFromUrl:(NSString*)imageUrl withCachedImage:(NSString*)cachedImageUrl forUIImageView:(UIImageView*)imageView;

@end
