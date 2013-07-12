//
//  CRTableViewController.m
//  CRMultiRowSelector
//
//  Created by Christian Roman on 6/17/12.
//  Copyright (c) 2012 chroman. All rights reserved.
//

#import "CRTableViewController.h"
#import "CRTableViewCell.h"
#import "AFNetworking.h"

@interface CRTableViewController () {}

@end

@implementation CRTableViewController

@synthesize dataSource;

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        //Check to see if some favourite languages have already been set.
        self.directories   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documents     = [self.directories lastObject];
        self.filePathLangs = [self.documents stringByAppendingPathComponent:@"langs.plist"];
        NSLog(@"DOCUMENTS &gt; %@", self.documents);
        
        NSMutableArray *loadedLangs = [NSMutableArray arrayWithContentsOfFile:self.filePathLangs];
        if (loadedLangs.count > 0) {
            selectedMarks = loadedLangs;
        } else {
            selectedMarks = [NSMutableArray new];
        }
        
        //Set up the view
        self.title = @"Favorite Languages";
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Done"
                                         style:UIBarButtonItemStyleDone
                                         target:self
                                         action:@selector(done:)];
        
        self.navigationItem.rightBarButtonItem = rightButton;
        
        //Add the languages
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://githubber.herokuapp.com/languages/top"]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"JSON: %@", JSON);
//            dataSource = (NSArray *)JSON;
            NSLog(@"datasource: %@", dataSource);
//            NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"first_name"], [JSON valueForKeyPath:@"last_name"]);
            [self.tableView reloadData];
        } failure:nil]; //TODO error message: http://www.raywenderlich.com/30445/afnetworking-crash-course
        [operation start];
        
        
//        dataSource = [
        
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
//    self.prefs = selectedMarks;//TODO Remove this
    
    [selectedMarks writeToFile:self.filePathLangs atomically:YES];
    
    NSArray *loadedLangs = [NSArray arrayWithContentsOfFile:self.filePathLangs];
    NSLog(@"Languages: %@", loadedLangs);
    
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
