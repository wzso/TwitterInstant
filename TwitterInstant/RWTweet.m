//
//  RWTweet.m
//  TwitterInstant
//
//  Created by Vincent on 3/7/17.
//  Copyright © 2017 Vincent. All rights reserved.
//

#import "RWTweet.h"

@implementation RWTweet
+ (instancetype)tweetWithStatus:(NSDictionary *)status {
    RWTweet *tweet = [RWTweet new];
    tweet.status = status[@"text"];
    
    NSDictionary *user = status[@"user"];
    tweet.profileImageUrl = user[@"profile_image_url"];
    tweet.username = user[@"screen_name"];
    return tweet;
}
@end
