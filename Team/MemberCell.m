//
//  MemberCell.m
//  Team
//
//  Created by Fouad Allaoui on 6/27/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "MemberCell.h"
#import "SlackService.h"

@implementation MemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateCellWithMember:(Members*)member andProfile:(Profiles*)profile {
    
    // Picture (default to 'member.png' if null)
    [[SlackService sharedManager] downloadImageFromUrl:[[profile valueForKey:@"thumbnailUrl"] description]
                                       withCachedImage:[[profile valueForKey:@"thumbnailCachedUrl"] description]
                                        forUIImageView:self.photo];
    
    // Username (default to 'Anonymous' if null)
    if ((![member valueForKey:@"name"]) || ([[[member valueForKey:@"name"] description] isEqualToString:@"(null)"])) {
        self.username.text = @"Anonymous";
    } else {
        self.username.text = [[member valueForKey:@"name"] description];
    }
    
    // Title (default to 'No Title' if null)
    if ((![profile valueForKey:@"title"]) || ([[[profile valueForKey:@"title"] description] isEqualToString:@"(null)"])) {
        self.title.text = @"No Title";
    } else {
        self.title.text = [[profile valueForKey:@"title"] description];
    }
    
    // Real Name (default to 'Anonymous')
    if ((![member valueForKey:@"realName"]) || ([[[member valueForKey:@"realName"] description] isEqualToString:@"(null)"])) {
        self.realName = @"Anonymous";
    } else {
        self.realName = [[member valueForKey:@"realName"] description];
    }
    
    // Email
    if ((![profile valueForKey:@"email"]) || ([[[profile valueForKey:@"email"] description] isEqualToString:@"(null)"])) {
        [self.emailButton setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
        self.email = @"";
    } else {
        self.email = [[profile valueForKey:@"email"] description];
        [self.emailButton setImage:[UIImage imageNamed:@"email_active"] forState:UIControlStateNormal];
    }
    
    // Phone
    if ((![profile valueForKey:@"phone"]) || ([[[profile valueForKey:@"phone"] description] isEqualToString:@"(null)"])) {
        [self.phoneButton setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        self.phone = @"";
    } else {
        self.phone = [[profile valueForKey:@"phone"] description];
        [self.phoneButton setImage:[UIImage imageNamed:@"phone_active"] forState:UIControlStateNormal];
    }
    
    // Skype
    if ((![profile valueForKey:@"skype"]) || ([[[profile valueForKey:@"skype"] description] isEqualToString:@"(null)"])) {
        [self.skypeButton setImage:[UIImage imageNamed:@"skype"] forState:UIControlStateNormal];
        self.skype = @"";
    } else {
        self.skype = [[profile valueForKey:@"skype"] description];
        [self.skypeButton setImage:[UIImage imageNamed:@"skype_active"] forState:UIControlStateNormal];
    }

    // Picture and thumbnail (default to member.png)
    if ((![profile valueForKey:@"pictureUrl"]) || ([[[profile valueForKey:@"pictureUrl"] description] isEqualToString:@"(null)"])) {
        self.pictureUrl = [[profile valueForKey:@"thumbnailUrl"] description];
    } else {
        self.pictureUrl = [[profile valueForKey:@"pictureUrl"] description];
    }

    self.cachedThumbnailUrl = [[profile valueForKey:@"thumbnailCachedUrl"] description];
}

@end
