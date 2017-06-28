//
//  MemberCell.h
//  Team
//
//  Created by Fouad Allaoui on 6/27/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberCell : UITableViewCell

// Displayed in the view
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *title;

// Not displayed in view (used for member detail view)
@property (nonatomic) NSString *pictureUrl;
@property (nonatomic) NSString *cachedThumbnailUrl;
@property (nonatomic) NSString *realName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *skype;

@end
