#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "RepoViewController.h"
#import "Reachability.h"

@interface RootViewController : UITableViewController <RepoViewControllerDelegate>
{
     Reachability *internetReachableFoo;
}
@property (nonatomic) BOOL shouldReload;
@end
