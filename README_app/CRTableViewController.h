#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface CRTableViewController : UITableViewController
{
    NSMutableArray *selectedMarks;
    NSMutableArray *dataArray;
}

@property (nonatomic) NSArray *dataSource;
@property (nonatomic, strong) NSArray *prefs;
@property (nonatomic, strong) UIViewController *parent;

@property (nonatomic, strong) NSArray *directories;
@property (nonatomic, strong) NSString *documents;
@property (nonatomic, strong) NSString *filePathLangs;

@end