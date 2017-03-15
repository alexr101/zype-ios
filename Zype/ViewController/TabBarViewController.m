//
//  TabBarViewController.m
//  
//
//  Created by Andrey Kasatkin on 3/14/17.
//
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (kDownloadsEnabled) {
        [self addDownloadsViewController];
    }
   
    
    // Do any additional setup after loading the view.
}

- (void)addDownloadsViewController {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    UIViewController *downloadsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DownloadsViewController"];
    [tabViewControllers addObject:downloadsViewController];
    [self setViewControllers:tabViewControllers];
}


@end
