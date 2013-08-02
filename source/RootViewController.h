#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "ReadmeViewController.h"
#import "Reachability.h"

@interface RootViewController : UITableViewController <ReadmeViewControllerDelegate>
{
     Reachability *internetReachableFoo;
}
@property (nonatomic) BOOL shouldReload;
@end
