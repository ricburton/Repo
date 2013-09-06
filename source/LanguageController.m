#import "LanguageController.h"
#import "TableViewCell.h"
#import "AFNetworking.h"
#import "RootViewController.h"

@interface LanguageController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *prefs;
@property (strong, nonatomic) UIViewController *parent;
@property (strong, nonatomic) NSArray *directories;
@property (strong, nonatomic) NSString *documents;
@property (strong, nonatomic) NSString *filePathLangs;
@property (strong, nonatomic) NSMutableArray *selectedMarks;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UIButton *saveBtn;

@end

@implementation LanguageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.directories   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documents     = [self.directories lastObject];
    self.filePathLangs = [self.documents stringByAppendingPathComponent:@"langs.plist"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,[[UIScreen mainScreen] bounds].size.height - 20) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithHexString:@"#32DDDDDD"];
    
    [[self navigationController] setNavigationBarHidden:YES];

    


    
    UIImage *settingsImg = [UIImage imageNamed:@"save_circle.png"];
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveBtn setImage:settingsImg forState:UIControlStateNormal];
    [self.saveBtn setFrame: CGRectMake([[UIScreen mainScreen] bounds].size.width - 133,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
    [self.saveBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 85.5, 10, 14.5)];
    [self.saveBtn setContentMode:UIViewContentModeCenter];
    [self.saveBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
    
    [self.tableView bringSubviewToFront:self.saveBtn];
}

- (void) viewDidAppear:(BOOL)animated {
    NSMutableArray *loadedLangs = [NSMutableArray arrayWithContentsOfFile:self.filePathLangs];
    if (loadedLangs.count > 0) {
        self.selectedMarks = loadedLangs;
    } else {
        self.selectedMarks = [NSMutableArray new];
    }
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    NSArray *topLanguages = [NSArray arrayWithObjects:@"JavaScript",@"Ruby",@"Java",@"Shell",@"Python",@"PHP",@"C",@"C++",@"Perl",@"CoffeeScript", nil];
    [self.dataArray addObject:topLanguages];
    
    NSArray *allLanguages = [NSArray arrayWithObjects: @"ABAP",@"ActionScript",@"Ada",@"Apex",@"AppleScript",@"Arc",@"Arduino",@"ASP",@"Assembly",@"Augeas",@"AutoHotkey",@"Awk",@"Boo",@"Bro",@"C#",@"Ceylon",@"CLIPS",@"Clojure",@"ColdFusion",@"Common%20Lisp",@"Coq",@"D",@"Dart",@"DCPU-16%20ASM",@"Delphi",@"DOT",@"Dylan",@"eC",@"Ecl",@"Eiffel",@"Elixir",@"Emacs%20Lisp",@"Erlang",@"F#",@"Factor",@"Fancy",@"Fantom",@"Forth",@"FORTRAN",@"Go",@"Gosu",@"Groovy",@"Haskell",@"Haxe",@"Io",@"Ioke",@"Julia",@"Kotlin",@"Lasso",@"LiveScript",@"Logos",@"Logtalk",@"Lua",@"M",@"Matlab",@"Max",@"Mirah",@"Monkey",@"MoonScript",@"Nemerle",@"Nimrod",@"Nu",@"Objective-C",@"Objective-J",@"OCaml",@"Omgrofl",@"ooc",@"Opa",@"OpenEdge%20ABL",@"Parrot",@"Pike",@"PogoScript",@"PowerShell",@"Processing",@"Prolog",@"Puppet",@"Pure%20Data",@"R",@"Racket",@"Ragel%20in%20Ruby%20Host",@"Rebol",@"Rouge",@"Rust",@"Scala",@"Scheme",@"Scilab",@"Self",@"Smalltalk",@"Standard%20ML",@"SuperCollider",@"Tcl",@"Turing",@"TXL",@"TypeScript",@"Vala",@"Verilog",@"VHDL",@"VimL",@"Visual%20Basic",@"wisp",@"XC",@"XML",@"XProc",@"XQuery",@"XSLT",@"Xtend", nil];
    
    [self.dataArray addObject:allLanguages];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *languageSection;
    if(section == 0){
         languageSection = @"Top Languages";
    } else if(section == 1){
         languageSection = @"All Languages";
    } else {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, self.tableView.frame.size.width, 35)];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [label setTextColor:[UIColor colorWithHexString:@"#4E575B"]];
    
    [label setText:languageSection];
    [view addSubview:label];
    
    [label setBackgroundColor:[UIColor colorWithHexString:@"E6EBED"]];
    [view setBackgroundColor:[UIColor colorWithHexString:@"E6EBED"]];
    return view;
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
    NSString *formattedLanguage = [text stringByReplacingOccurrencesOfString:@"%20"
                                                                    withString:@" "];
    cell.textLabel.text = formattedLanguage;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#555"];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 35;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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
