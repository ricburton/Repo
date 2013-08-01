#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "ReadmeViewController.h"

@interface RootViewController : UITableViewController <ReadmeViewControllerDelegate>
@property (nonatomic) BOOL shouldReload;
@end
