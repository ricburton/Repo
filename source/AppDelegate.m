#import "AppDelegate.h"
#import "TableViewController.h"
#import "RootViewController.h"
#import "Flurry.h"

@implementation AppDelegate

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
