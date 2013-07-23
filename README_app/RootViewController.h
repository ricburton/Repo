//
//  RootViewController.h
//  CRMultiRowSelector
//
//  Created by Richard Burton on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import "CRTableViewController.h"

@interface RootViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataArray;
    NSDictionary *response_data;
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic) NSArray *arrayOfLangs;
@property (nonatomic) NSString *arrayOfLangsOld;
@property (strong, nonatomic) NSArray *langPrefs;
@property (strong, nonatomic) UINavigationController *langTable;
@property (strong, nonatomic) UITableViewController *langList; // why did this change?
@property (strong, nonatomic) NSString *langPrefsPath;

@property (nonatomic, strong) NSArray *directories;
@property (nonatomic, strong) NSString *documents;
@property (nonatomic, strong) NSString *filePathLangs;

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@end
