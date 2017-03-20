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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Accounts/Accounts.h> 
#import <Social/Social.h>


typedef NS_ENUM(NSInteger, RWTwitterInstantError) {
    RWTwitterInstantErrorAccessDenied,
    RWTwitterInstantErrorNoTwitterAccounts,
    RWTwitterInstantErrorInvalidResponse
};

static NSString * const RWTwitterInstantDomain = @"TwitterInstant";


@interface DetailViewController ()
@property (nonatomic, strong) NSArray *tweets;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *twitterAccountType;
@end

@implementation DetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountStore = [[ACAccountStore alloc] init];
    self.twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [[self requestToAccessTwitterSigal] subscribeNext:^(id x) {
        NSLog(@"Succeed!");
    } error:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)displayTweets:(NSArray *)tweets {
    self.tweets = tweets;
    [self.tableView reloadData];
}

- (RACSignal *)requestToAccessTwitterSigal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.accountStore
         requestAccessToAccountsWithType:self.twitterAccountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
           if (granted) {
               [subscriber sendNext:nil];
               [subscriber sendCompleted];
           }
           else {
               NSError *accessError = [NSError errorWithDomain:RWTwitterInstantDomain code:RWTwitterInstantErrorAccessDenied userInfo:nil];
               [subscriber sendError:accessError];
           }
        }];
        return nil;
    }];
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
    
    return cell;
}
@end
