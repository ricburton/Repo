#import "TableViewController.h"
#import "TableViewCell.h"
#import "AFNetworking.h"
#import "RootViewController.h"

@interface TableViewController ()

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
        
        NSArray *allLanguages = [NSArray arrayWithObjects: @"ABAP",@"ActionScript",@"Ada",@"Apex",@"AppleScript",@"Arc",@"Arduino",@"ASP",@"Assembly",@"Augeas",@"AutoHotkey",@"Awk",@"Boo",@"Bro",@"C#",@"Ceylon",@"CLIPS",@"Clojure",@"ColdFusion",@"Common%20Lisp",@"Coq",@"D",@"Dart",@"DCPU-16%20ASM",@"Delphi",@"DOT",@"Dylan",@"eC",@"Ecl",@"Eiffel",@"Elixir",@"Emacs%20Lisp",@"Erlang",@"F#",@"Factor",@"Fancy",@"Fantom",@"Forth",@"FORTRAN",@"Go",@"Gosu",@"Groovy",@"Haskell",@"Haxe",@"Io",@"Ioke",@"Julia",@"Kotlin",@"Lasso",@"LiveScript",@"Logos",@"Logtalk",@"Lua",@"M",@"Matlab",@"Max",@"Mirah",@"Monkey",@"MoonScript",@"Nemerle",@"Nimrod",@"Nu",@"Objective-C",@"Objective-J",@"OCaml",@"Omgrofl",@"ooc",@"Opa",@"OpenEdge%20ABL",@"Parrot",@"Pike",@"PogoScript",@"PowerShell",@"Processing",@"Prolog",@"Puppet",@"Pure%20Data",@"R",@"Racket",@"Ragel%20in%20Ruby%20Host",@"Rebol",@"Rouge",@"Rust",@"Scala",@"Scheme",@"Scilab",@"Self",@"Smalltalk",@"Standard%20ML",@"SuperCollider",@"Tcl",@"Turing",@"TXL",@"TypeScript",@"Vala",@"Verilog",@"VHDL",@"VimL",@"Visual%20Basic",@"wisp",@"XC",@"XML",@"XProc",@"XQuery",@"XSLT",@"Xtend", nil];
        
        [self.dataArray addObject:allLanguages];
        
    }
    return self;
}

//TODO - Move this repeated code to a Pod
- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    unsigned int hexint = [self intFromHexString:hexStr];
    
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES];
    [self.tableView reloadData];
    self.tableView.separatorColor = [self getUIColorObjectFromHexString:@"#DDDDDD" alpha:.32];
    
    UIImage *settingsImg = [UIImage imageNamed:@"save_circle.png"];
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveBtn setBackgroundImage:settingsImg forState:UIControlStateNormal];
    self.saveBtn.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 38,[[UIScreen mainScreen] bounds].size.height - 63,33,33);//
    [self.saveBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect fixedFrame = self.saveBtn.frame;
    fixedFrame.origin.y = ([[UIScreen mainScreen] bounds].size.height - 63) + scrollView.contentOffset.y;
    self.saveBtn.frame = fixedFrame;
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
    [label setTextColor:[self getUIColorObjectFromHexString:@"#4E575B" alpha:1]];
    
    [label setText:languageSection];
    [view addSubview:label];
    
    [label setBackgroundColor:[self getUIColorObjectFromHexString:@"E6EBED" alpha:1]];
    [view setBackgroundColor:[self getUIColorObjectFromHexString:@"E6EBED" alpha:1]];
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
    cell.textLabel.textColor = [self getUIColorObjectFromHexString:@"#555555" alpha:1];
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
