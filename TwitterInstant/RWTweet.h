//
//  RWTweet.h
//  TwitterInstant
//
//  Created by Vincent on 3/7/17.
//  Copyright © 2017 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWTweet : NSObject
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *profileImageUrl;
@property (copy, nonatomic) NSString *username;

+ (instancetype)tweetWithStatus:(NSDictionary *)status;
@end
