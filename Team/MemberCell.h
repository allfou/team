//
//  MemberCell.h
//  Team
//
//  Created by Fouad Allaoui on 6/27/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *usename;
@property (weak, nonatomic) IBOutlet UILabel *email;

@end
