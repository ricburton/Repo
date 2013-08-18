#import "Tokens.h"
#import "AppDelegate.h"
#import "TableViewController.h"
#import "RootViewController.h"
#import "Mixpanel.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    RootViewController *rootView = [[RootViewController alloc] init];
    rootView.shouldReload = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootView];
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
