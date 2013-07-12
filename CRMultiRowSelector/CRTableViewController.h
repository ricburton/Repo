//
//  CRTableViewController.h
//  CRMultiRowSelector
//
//  Created by Christian Roman on 6/17/12.
//  Copyright (c) 2012 chroman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface CRTableViewController : UITableViewController
{
//    NSArray *dataSource;
    NSMutableArray *selectedMarks;
}

@property (nonatomic) NSArray *dataSource;
@property (nonatomic, strong) NSArray *prefs;
@property (nonatomic, strong) UIViewController *parent;

@property (nonatomic, strong) NSArray *directories;
@property (nonatomic, strong) NSString *documents;
@property (nonatomic, strong) NSString *filePathLangs;

@end