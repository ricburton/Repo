#import "TableViewController.h"
#import "TableViewCell.h"
#import "AFNetworking.h"

@interface TableViewController ()

@property (nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *prefs;
@property (strong, nonatomic) UIViewController *parent;
@property (strong, nonatomic) NSArray *directories;
@property (strong, nonatomic) NSString *documents;
@property (strong, nonatomic) NSString *filePathLangs;
@property (strong, nonatomic) NSMutableArray *selectedMarks;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end


@implementation TableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.directories   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documents     = [self.directories lastObject];
        self.filePathLangs = [self.documents stringByAppendingPathComponent:@"langs.plist"];
        
        NSMutableArray *loadedLangs = [NSMutableArray arrayWithContentsOfFile:self.filePathLangs];
        if (loadedLangs.count > 0) {
            self.selectedMarks = loadedLangs;
        } else {
            self.selectedMarks = [NSMutableArray new];
        }
        
        self.dataArray = [[NSMutableArray alloc] init];
        
        NSArray *topLanguages = [NSArray arrayWithObjects:@"JavaScript",@"Ruby",@"Java",@"Shell",@"Python",@"PHP",@"C",@"C++",@"Perl",@"CoffeeScript", nil];
        [self.dataArray addObject:topLanguages];
        
        NSArray *allLanguages = [NSArray arrayWithObjects: @"ABAP",@"ActionScript",@"Ada",@"Apex",@"AppleScript",@"Arc",@"Arduino",@"ASP",@"Assembly",@"Augeas",@"AutoHotkey",@"Awk",@"Boo",@"Bro",@"C#",@"Ceylon",@"CLIPS",@"Clojure",@"ColdFusion",@"Common Lisp",@"Coq",@"D",@"Dart",@"DCPU-16 ASM",@"Delphi",@"DOT",@"Dylan",@"eC",@"Ecl",@"Eiffel",@"Elixir",@"Emacs Lisp",@"Erlang",@"F#",@"Factor",@"Fancy",@"Fantom",@"Forth",@"FORTRAN",@"Go",@"Gosu",@"Groovy",@"Haskell",@"Haxe",@"Io",@"Ioke",@"Julia",@"Kotlin",@"Lasso",@"LiveScript",@"Logos",@"Logtalk",@"Lua",@"M",@"Matlab",@"Max",@"Mirah",@"Monkey",@"MoonScript",@"Nemerle",@"Nimrod",@"Nu",@"Objective-C",@"Objective-J",@"OCaml",@"Omgrofl",@"ooc",@"Opa",@"OpenEdge ABL",@"Parrot",@"Pike",@"PogoScript",@"PowerShell",@"Processing",@"Prolog",@"Puppet",@"Pure Data",@"R",@"Racket",@"Ragel in Ruby Host",@"Rebol",@"Rouge",@"Rust",@"Scala",@"Scheme",@"Scilab",@"Self",@"Smalltalk",@"Standard ML",@"SuperCollider",@"Tcl",@"Turing",@"TXL",@"TypeScript",@"Vala",@"Verilog",@"VHDL",@"VimL",@"Visual Basic",@"wisp",@"XC",@"XML",@"XProc",@"XQuery",@"XSLT",@"Xtend", nil];
        
        [self.dataArray addObject:allLanguages];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Favorite Languages";
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Done"
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(done:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIDeviceOrientationPortrait){
        return YES;
    } else {
        return NO;
    }
}

- (void)done:(id)sender
{
    [self.selectedMarks writeToFile:self.filePathLangs atomically:YES];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
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
    
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CRTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CRTableViewCellIdentifier];
    }
    
    NSArray *array = [self.dataArray objectAtIndex:indexPath.section];
    NSString *text = [array objectAtIndex:indexPath.row];
    cell.isSelected = [self.selectedMarks containsObject:text];
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedCell = nil;
    NSArray *array = [self.dataArray objectAtIndex:indexPath.section];
    selectedCell = [array objectAtIndex:indexPath.row];
    
    if ([self.selectedMarks containsObject:selectedCell]) {
        [self.selectedMarks removeObject:selectedCell];
    } else {
        [self.selectedMarks addObject:selectedCell];
    }
    
    NSLog(@"%@", selectedCell);
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
