//
//  MasterViewController.m
//  TwitterInstant
//
//  Created by Vincent on 3/7/17.
//  Copyright © 2017 Vincent. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <NSArray+LinqExtensions.h>
#import "RWTweet.h"

static NSString * const RWTwitterInstantDomain = @"TwitterInstant";

typedef NS_ENUM(NSInteger, RWTwitterInstantError) {
    RWTwitterInstantErrorAccessDenied,
    RWTwitterInstantErrorNoTwitterAccounts,
    RWTwitterInstantErrorInvalidResponse
};

@interface MasterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *twitterAccountType;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    NSLog(@"View Controllers: %@", self.splitViewController.viewControllers);
    self.accountStore = [[ACAccountStore alloc] init];
    self.twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    @weakify(self)
    [[[[[[self requestToAccessTwitterSigal] then:^RACSignal *{
        @strongify(self)
        return self.searchTF.rac_textSignal;
    }]
    filter:^BOOL(NSString *text) {
        return text.length >= 4;
    }]
    flattenMap:^RACStream *(NSString *text) {
        @strongify(self)
        return [self signalForSearchWithText:text];
    }]
    // There’s just one simple operation for marshalling the flow of events onto a different thread? Just how awesome is that!?
    deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(NSDictionary *searchResult) {
        @strongify(self)
        NSLog(@"response: %@", searchResult);
        NSArray *statuses = searchResult[@"statuses"];
        NSArray *tweets = [statuses linq_select:^id(id item) {
            return [RWTweet tweetWithStatus:item];
        }];
        [self.detailViewController displayTweets:tweets];
    } error:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
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

- (RACSignal *)signalForSearchWithText:(NSString *)text {
    // 1 - define the errors
    NSError *noAccountsError = [NSError errorWithDomain:RWTwitterInstantDomain                                                  code:RWTwitterInstantErrorNoTwitterAccounts                                              userInfo:nil];
    NSError *invalidResponseError = [NSError errorWithDomain:RWTwitterInstantDomain                                                       code:RWTwitterInstantErrorInvalidResponse                                                   userInfo:nil];
    
    // 2 - create the signal block
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        // 3 - create the request
        SLRequest *request = [self requestForTwitterSearchWithText:text];
        // 4 - supply the twitter account
        NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:self.twitterAccountType];
        if (twitterAccounts.count == 0) {
            [subscriber sendError:noAccountsError];
        }
        else {
            [request setAccount:twitterAccounts.lastObject];
            // 5 - perform the request
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (urlResponse.statusCode == 200) {
                    // 6 - on success, parse the response
                    NSDictionary *timelineDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                    [subscriber sendNext:timelineDict];
                    [subscriber sendCompleted];
                }
                else {
                    // 7 - on failure, send an error
                    [subscriber sendError:invalidResponseError];
                }
            }];
        }
        return nil;
    }];
}

- (SLRequest *)requestForTwitterSearchWithText:(NSString *)text {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    NSDictionary *param = @{@"q" : text};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:param];
    return request;
}
     
#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
    }
}
     
@end
