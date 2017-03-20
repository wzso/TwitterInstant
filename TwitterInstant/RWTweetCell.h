//
//  RWTweetCell.h
//  TwitterInstant
//
//  Created by Vincent on 3/7/17.
//  Copyright © 2017 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWTweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *twitterAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *twitterStatusText;
@property (weak, nonatomic) IBOutlet UILabel *twitterUsernameText;
@end
