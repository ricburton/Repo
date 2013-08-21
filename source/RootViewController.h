#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "RepoViewController.h"
#import "Reachability.h"
#import "OctoKit.h"

@interface RootViewController : UITableViewController <RepoViewControllerDelegate>
{
     Reachability *internetReachableFoo;
}
@property (nonatomic) BOOL shouldReload;
@property (nonatomic) NSString *keychainToken;
@property (strong, nonatomic) OCTClient *client;
@end
