//
//  RootViewController.h
//  CRMultiRowSelector
//
//  Created by Richard Burton on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import "CRTableViewController.h"

@interface RootViewController : UIViewController
@property (strong, nonatomic) UILabel *langLabel;
@property (strong, nonatomic) NSArray *latestProjects;
@property (strong, nonatomic) UILabel *latestProjectsLabel;
@property (strong, nonatomic) NSArray *langPrefs;
@property (strong, nonatomic) UINavigationController *langTable;
@property (strong, nonatomic) UITableViewController *langList; // why did this change?
@property (strong, nonatomic) NSString *langPrefsPath;
@end
