//
//  CRTableViewController.m
//  CRMultiRowSelector
//
//  Created by Christian Roman on 6/17/12.
//  Copyright (c) 2012 chroman. All rights reserved.
//

#import "CRTableViewController.h"
#import "CRTableViewCell.h"

@interface CRTableViewController ()

@end

@implementation CRTableViewController

@synthesize dataSource;

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.title = @"Favorite Languages";
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Done"
                                         style:UIBarButtonSystemItemDone
                                         target:self
                                         action:@selector(done:)];
        
        self.navigationItem.rightBarButtonItem = rightButton;
        
        dataSource = [[NSArray alloc] initWithObjects: @"JavaScript", @"Ruby", @"Java", @"Python", @"Shell", @"PHP", @"C", @"C++", @"Perl", @"Objective-C", nil];
        
        selectedMarks = [NSMutableArray new];
//        selectedMarks = [[NSMutableArray alloc] initWithContentsOfFile:[(RootViewController *)self.parent langPrefsPath]];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIDeviceOrientationPortrait) return YES;
    return NO;
}

#pragma mark - Methods
- (void)done:(id)sender
{
    NSLog(@"%@", selectedMarks);
//    [self presentViewController:RootViewController animated:YES completion:nil];
    self.prefs = selectedMarks;
    
//    [(RootViewController *)self.parent setLangPrefs:selectedMarks];
    
    //String Path of file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Documents" ofType:@"plist"];
    [(RootViewController *)self.parent setLangPrefsPath:path];
    
    //Save
    [selectedMarks writeToFile:path atomically:YES];
    [self dismissModalViewControllerAnimated:TRUE];
}

#pragma mark - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CRTableViewCellIdentifier = @"cellIdentifier";
    
    // init the CRTableViewCell
    CRTableViewCell *cell = (CRTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CRTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[CRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CRTableViewCellIdentifier];
    }
    
    // Check if the cell is currently selected (marked)
    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    cell.isSelected = [selectedMarks containsObject:text] ? YES : NO;
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    
    if ([selectedMarks containsObject:text])// Is selected?
        [selectedMarks removeObject:text];
    else
        [selectedMarks addObject:text];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
