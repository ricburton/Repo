#import "CRAppDelegate.h"
#import "CRTableViewController.h"
#import "RootViewController.h"
#import "Flurry.h"

@implementation CRAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"H23Z9B4RNC39NMF56JP6"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    RootViewController *rootView = [[RootViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootView];
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
