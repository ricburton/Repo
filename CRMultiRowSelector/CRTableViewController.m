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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialize the dataArray
    dataArray = [[NSMutableArray alloc] init];
    
    //Add the languages
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://githubber.herokuapp.com/languages"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"top"], [JSON valueForKeyPath:@"all"]);
        
        //Top Languages
        NSArray *topLanguages = (NSArray *) [JSON valueForKeyPath:@"top"];
        NSDictionary *topLanguagesDict = [NSDictionary dictionaryWithObject:topLanguages forKey:@"data"];
        [dataArray addObject:topLanguagesDict];
        
        //All Languages section data
        NSArray *allLanguages = (NSArray *) [JSON valueForKeyPath:@"all"];
        NSDictionary *allLanguagesDict = [NSDictionary dictionaryWithObject:allLanguages forKey:@"data"];
        [dataArray addObject:allLanguagesDict];
        
        [self.tableView reloadData];
    } failure:nil];//^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {NSLog(@"JSON Error")}; //TODO error message: http://www.raywenderlich.com/30445/afnetworking-crash-course
    [operation start];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Top Languages";
    if(section == 1)
        return @"All Languages";
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
//    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *text = [array objectAtIndex:indexPath.row];
    cell.isSelected = [selectedMarks containsObject:text] ? YES : NO;
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *selectedCell = nil;
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    selectedCell = [array objectAtIndex:indexPath.row];
    
    if ([selectedMarks containsObject:selectedCell])// Is selected?
        [selectedMarks removeObject:selectedCell];
    else
        [selectedMarks addObject:selectedCell];
    
    NSLog(@"%@", selectedCell);
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
