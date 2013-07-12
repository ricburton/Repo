//
//  RootViewController.h
//  CRMultiRowSelector
//
//  Created by Richard Burton on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import "CRTableViewController.h"

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
//     NSArray *arrayOfLangs;
}

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *arrayOfLangs;
@property (strong, nonatomic) NSArray *langPrefs;
@property (strong, nonatomic) UINavigationController *langTable;
@property (strong, nonatomic) UITableViewController *langList; // why did this change?
@property (strong, nonatomic) NSString *langPrefsPath;

@property (nonatomic, strong) NSArray *directories;
@property (nonatomic, strong) NSString *documents;
@property (nonatomic, strong) NSString *filePathLangs;
@end
