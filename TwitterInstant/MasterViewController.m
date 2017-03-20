//
//  MasterViewController.m
//  TwitterInstant
//
//  Created by Vincent on 3/7/17.
//  Copyright © 2017 Vincent. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    NSLog(@"View Controllers: %@", self.splitViewController.viewControllers);
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
    }
}
@end
