#import "RootViewController.h"
#import "TableViewController.h"
#import "AFNetworking.h"
#import "ReadmeViewController.h"
#import "RMCustomCell.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSDictionary *response_data;
@property (strong, nonatomic) NSArray *arrayOfLangs;
@property (strong, nonatomic) NSArray *langPrefs;
@property (strong, nonatomic) NSString *langPrefsPath;
@property (strong, nonatomic) NSArray *directories;
@property (strong, nonatomic) NSString *documents;
@property (strong, nonatomic) NSString *filePathLangs;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) MBProgressHUD *sad_hud;

@end

@implementation RootViewController
{
    AFJSONRequestOperation *operation;
    UIBarButtonItem *langButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"README";
    
    langButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Settings"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(settings:)];
    
    self.navigationItem.rightBarButtonItem = langButton;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;    
}

- (void)addItemViewController:(ReadmeViewController *)controller didFinishEnteringItem:(BOOL)item
{
    NSLog(@"This was returned from the ReadmeViewController %hhd",item);
    self.shouldReload = item;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self testInternetConnection];
}

- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            
            [self.sad_hud hide:YES];
            self.tableView.allowsSelection = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            self.directories   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            self.documents     = [self.directories lastObject];
            self.filePathLangs = [self.documents stringByAppendingPathComponent:@"langs.plist"];
            NSLog(@"DOCUMENTS: %@", self.documents);
            NSLog(@"Reload?: %hhd", self.shouldReload);
            self.arrayOfLangs = [NSMutableArray arrayWithContentsOfFile:self.filePathLangs];
            if (self.arrayOfLangs.count == 0){
                [self settings:nil];
            } else if (self.shouldReload == NO ) {
                NSLog(@"Don't reload!");
            } else {
                
                NSLog(@"PASS");
                
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.arrayOfLangs, @"languages", nil];
                
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://githubber.herokuapp.com"]];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                        path:@"/readmes"
                                                                  parameters:params];
                NSLog(@"Request: %@",params);
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
                self.hud.mode = MBProgressHUDModeIndeterminate;
                self.hud.animationType = MBProgressHUDAnimationZoomIn;
                self.hud.labelText = @"Loading";
                
                operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    self.response_data = JSON;
                    
                    self.dataArray = [[NSMutableArray alloc]init];
                    
                    for( NSString* language in self.arrayOfLangs )
                    {
                        NSString *contests = [self.response_data valueForKeyPath:[NSString stringWithFormat:@"%@.contest",language]];
                        
                        NSString *readme_url_data = [NSString stringWithFormat:@"%@.readme_url",language];
                        NSLog(@"readme_url_data: %@",readme_url_data);
                        NSArray *readme_urls = [self.response_data valueForKeyPath:readme_url_data];
                        
                        NSArray *descriptions = [self.response_data valueForKeyPath:[NSString stringWithFormat:@"%@.description",language]];
                        
                        if (descriptions && readme_urls) {
                            NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:descriptions forKey:@"descriptions"];
                            [dataDict setObject:readme_urls forKey:@"readme_url"];
                            [dataDict setObject:contests forKey:@"contest"];
                            
                            [self.dataArray addObject:dataDict];
                        } else {
                            NSLog(@"No stars or forks");
                            NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:@[@"NOTHING"] forKey:@"descriptions"];
                            [dataDict setObject:@[@"NOTHING"] forKey:@"readme_url"];
                            [self.dataArray addObject:dataDict];
                        }
                    }
                    
                    [self.hud hide:YES];
                    [self.tableView reloadData];
                    
                } failure:nil];
            }
            [operation start];
            if (self.hud.hidden == NO) { //Double check it's gone
                [self.hud hide:YES];
            }
        });
    };
    
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            self.sad_hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            self.sad_hud.mode = MBProgressHUDModeText;
            self.sad_hud.animationType = MBProgressHUDAnimationZoomIn;
            self.sad_hud.labelText = @"No internet.";
            
            self.tableView.allowsSelection = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            [self.hud hide:YES];
        });
    };
    
    [internetReachableFoo startNotifier];
}


- (void)settings:(id)sender
{
    [self.sad_hud hide:YES];
    TableViewController *langList = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *langTable = [[UINavigationController alloc] initWithRootViewController:langList];
    [self presentViewController:langTable animated:YES completion:nil];
    self.shouldReload = YES;
}


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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *colorDic = @{@"Arduino":@"#bd79d1",@"Java":@"#b07219",@"VHDL":@"#543978",@"Scala":@"#7dd3b0",@"Emacs Lisp":@"#c065db",@"Delphi":@"#b0ce4e",@"Ada":@"#02f88c",@"VimL":@"#199c4b",@"Perl":@"#0298c3",@"Lua":@"#fa1fa1",@"Rebol":@"#358a5b",@"Verilog":@"#848bf3",@"Factor":@"#636746",@"Ioke":@"#078193",@"R":@"#198ce7",@"Erlang":@"#949e0e",@"Nu":@"#c9df40",@"AutoHotkey":@"#6594b9",@"Clojure":@"#db5855",@"Shell":@"#5861ce",@"Assembly":@"#a67219",@"Parrot":@"#f3ca0a",@"C#":@"#5a25a2",@"Turing":@"#45f715",@"AppleScript":@"#3581ba",@"Eiffel":@"#946d57",@"Common%20Lisp":@"#3fb68b",@"Dart":@"#cccccc",@"SuperCollider":@"#46390b",@"CoffeeScript":@"#244776",@"XQuery":@"#2700e2",@"Haskell":@"#29b544",@"Racket":@"#ae17ff",@"Elixir":@"#6e4a7e",@"HaXe":@"#346d51",@"Ruby":@"#701516",@"Self":@"#0579aa",@"Fantom":@"#dbded5",@"Groovy":@"#e69f56",@"C":@"#555",@"JavaScript":@"#f15501",@"D":@"#fcd46d",@"ooc":@"#b0b77e",@"C++":@"#f34b7d",@"Dylan":@"#3ebc27",@"Nimrod":@"#37775b",@"Standard ML":@"#dc566d",@"Objective-C":@"#438eff",@"Nemerle":@"#0d3c6e",@"Mirah":@"#c7a938",@"Boo":@"#d4bec1",@"Objective-J":@"#ff0c5a",@"Rust":@"#dea584",@"Prolog":@"#74283c",@"Ecl":@"#8a1267",@"Gosu":@"#82937f",@"FORTRAN":@"#4d41b1",@"ColdFusion":@"#ed2cd6",@"OCaml":@"#3be133",@"Fancy":@"#7b9db4",@"Pure%20Data":@"#f15501",@"Python":@"#3581ba",@"Tcl":@"#e4cc98",@"Arc":@"#ca2afe",@"Puppet":@"#cc5555",@"Io":@"#a9188d",@"Max":@"#ce279c",@"Go":@"#8d04eb",@"ASP":@"#6a40fd",@"Visual Basic":@"#945db7",@"PHP":@"#6e03c1",@"Scheme":@"#1e4aec",@"Vala":@"#3581ba",@"Smalltalk":@"#596706",@"Matlab":@"#bb92ac",@"C#":@"#bb92af"};

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, self.tableView.frame.size.width, 35)];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [label setTextColor:[self getUIColorObjectFromHexString:@"#ffffff" alpha:1]];
    NSString *string = self.arrayOfLangs[section];
    
    NSString *formattedLanguage = [string stringByReplacingOccurrencesOfString:@"%20"
                                                                          withString:@" "];
    [label setText:formattedLanguage];
    [view addSubview:label];
    NSLog(@"langString: %@", string);
    NSString *sectionColor;
    if ([colorDic objectForKey:string]) {
        sectionColor = [colorDic objectForKey:string];
    } else {
        sectionColor = @"#4A4A4A";
    }
    [label setBackgroundColor:[self getUIColorObjectFromHexString:sectionColor alpha:1]];
    [view setBackgroundColor:[self getUIColorObjectFromHexString:sectionColor alpha:1]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 35;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [self.dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"descriptions"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell Identifier";
    RMCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[RMCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [self.dataArray objectAtIndex:indexPath.section];
    NSArray *readmeArray = [dictionary objectForKey:@"descriptions"];
    NSString *readmeText = [readmeArray objectAtIndex:indexPath.row];
    
    NSArray *readmeURLArray = [dictionary objectForKey:@"readme_url"];
    NSString *readmeURL = [readmeURLArray objectAtIndex:indexPath.row];
    
    NSArray *contestArray = [dictionary objectForKey:@"contest"];
    NSString *contest = [contestArray objectAtIndex:indexPath.row];
    
    NSLog(@"readmeURL: %@", readmeURL);
    if ([readmeURL isEqualToString: @"NOTHING"]) {
        NSLog(@"No stars or forks");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"No projects starred or forked.";
        cell.detailTextLabel.text = @"Go give the language some love :)";
        
        return cell;
    } else if ([readmeURL isEqualToString: @"Readme link unavailable."]){
        return cell;
    } else {
        
        NSString *readmeURLStrip = [readmeURL stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
        NSRange range = [readmeURLStrip rangeOfString:@"/blob/"];//FIXME sometimes not a blob.
        NSString *repoTitleFull = [readmeURLStrip substringToIndex:range.location];
        NSString *repoTitle = [repoTitleFull stringByReplacingOccurrencesOfString:@"/" withString:@" / "];

        const CGFloat fontSize = 13;
        UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
        UIColor *boldColor  = [self getUIColorObjectFromHexString:@"#3A85D6" alpha:1];
        UIFont *slashFont = [UIFont boldSystemFontOfSize:fontSize];
        UIColor *slashColor = [self getUIColorObjectFromHexString:@"#999999" alpha:1];
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               boldColor, NSForegroundColorAttributeName,
                               nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  slashFont, NSFontAttributeName,
                                  slashColor, NSForegroundColorAttributeName,
                                  nil];
        const NSRange rangeSlash = [repoTitle rangeOfString:@"/"];
        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:repoTitle
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:rangeSlash];
        
        cell.backgroundColor      = [self getUIColorObjectFromHexString:@"#FBFBFB" alpha:1];
        [cell.textLabel setAttributedText:attributedText];
        
        cell.detailTextLabel.text = readmeText;
        cell.detailTextLabel.textColor  = [self getUIColorObjectFromHexString:@"#555555" alpha:1];//#333335
        NSLog(@"Contest string: %@",contest);
        if ([contest isEqualToString:@"most_forked_today"]) {
            cell.contestIcon.image    = [UIImage imageNamed:@"most_forked.png"];
        } else if ([contest isEqualToString:@"most_starred_today"]) {
            cell.contestIcon.image    = [UIImage imageNamed:@"most_starred.png"];
        } else if ([contest isEqualToString:@"most_starred_and_forked_today"]) {
            cell.contestIcon.image    = [UIImage imageNamed:@"most_starred_and_forked.png"];
        }
         
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [self.dataArray objectAtIndex:indexPath.section];
    NSArray *readmeURLArray = [dictionary objectForKey:@"readme_url"];
    NSString *readmeURL = [readmeURLArray objectAtIndex:indexPath.row];
    
    ReadmeViewController *webView = [[ReadmeViewController alloc] init];
    webView.url = [NSURL URLWithString:readmeURL];
    webView.delegate = self;
    [self.sad_hud hide:YES];
    
    [self presentViewController:webView animated:YES completion:nil];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end

