//
//  DetailViewController.m
//  TwitterInstant
//
//  Created by Vincent on 3/7/17.
//  Copyright © 2017 Vincent. All rights reserved.
//

#import "DetailViewController.h"
#import "RWTweet.h"
#import "RWTweetCell.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>



@interface DetailViewController ()
@property (nonatomic, strong) NSArray *tweets;
@end

@implementation DetailViewController

- (void)displayTweets:(NSArray *)tweets {
    self.tweets = tweets;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    RWTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RWTweet *tweet = self.tweets[indexPath.row];
    cell.twitterStatusText.text = tweet.status;
    cell.twitterUsernameText.text = [NSString stringWithFormat:@"@%@",tweet.username];
    cell.twitterAvatarView.image = nil;
    [[[self signalForLoadingImageWithURL:tweet.profileImageUrl]
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(UIImage *image) {
        cell.twitterAvatarView.image = image;
    }];
    return cell;
}

- (RACSignal *)signalForLoadingImageWithURL:(NSString *)url {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}

@end
