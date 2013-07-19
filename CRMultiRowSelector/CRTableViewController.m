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
    
    
    NSArray *topLanguages = [NSArray arrayWithObjects:@"JavaScript",@"Ruby",@"Java",@"Shell",@"Python",@"PHP",@"C",@"C++",@"Perl",@"CoffeeScript", nil];
    NSDictionary *topLanguagesDict = [NSDictionary dictionaryWithObject:topLanguages forKey:@"data"];
    [dataArray addObject:topLanguagesDict];
    
    //All Languages section data
    NSArray *allLanguages = [NSArray arrayWithObjects: @"ABAP",@"ActionScript",@"Ada",@"Apex",@"AppleScript",@"Arc",@"Arduino",@"ASP",@"Assembly",@"Augeas",@"AutoHotkey",@"Awk",@"Boo",@"Bro",@"C#",@"Ceylon",@"CLIPS",@"Clojure",@"ColdFusion",@"Common Lisp",@"Coq",@"D",@"Dart",@"DCPU-16 ASM",@"Delphi",@"DOT",@"Dylan",@"eC",@"Ecl",@"Eiffel",@"Elixir",@"Emacs Lisp",@"Erlang",@"F#",@"Factor",@"Fancy",@"Fantom",@"Forth",@"FORTRAN",@"Go",@"Gosu",@"Groovy",@"Haskell",@"Haxe",@"Io",@"Ioke",@"Julia",@"Kotlin",@"Lasso",@"LiveScript",@"Logos",@"Logtalk",@"Lua",@"M",@"Matlab",@"Max",@"Mirah",@"Monkey",@"MoonScript",@"Nemerle",@"Nimrod",@"Nu",@"Objective-C",@"Objective-J",@"OCaml",@"Omgrofl",@"ooc",@"Opa",@"OpenEdge ABL",@"Parrot",@"Pike",@"PogoScript",@"PowerShell",@"Processing",@"Prolog",@"Puppet",@"Pure Data",@"R",@"Racket",@"Ragel in Ruby Host",@"Rebol",@"Rouge",@"Rust",@"Scala",@"Scheme",@"Scilab",@"Self",@"Smalltalk",@"Standard ML",@"SuperCollider",@"Tcl",@"Turing",@"TXL",@"TypeScript",@"Vala",@"Verilog",@"VHDL",@"VimL",@"Visual Basic",@"wisp",@"XC",@"XML",@"XProc",@"XQuery",@"XSLT",@"Xtend", nil];
    NSDictionary *allLanguagesDict = [NSDictionary dictionaryWithObject:allLanguages forKey:@"data"];
    [dataArray addObject:allLanguagesDict];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{

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
 
    [selectedMarks writeToFile:self.filePathLangs atomically:YES];
    
//    NSArray *loadedLangs = [NSArray arrayWithContentsOfFile:self.filePathLangs];
    
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
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
    
    if(section == 0){
        return @"Top Languages";
    } else if(section == 1){
        return @"All Languages";
    } else {
        return nil;   
    }
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
