#import "RootViewController.h"
#import "TableViewController.h"
#import "AFNetworking.h"
#import "RepoViewController.h"
#import "RMCustomCell.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "OctoKit.h"
#import "GithubOAuth.h"
#import "RFKeychain.h"
#import "KGModal.h"

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
@property (strong, nonatomic) UIButton *settingsBtn;

@end

@implementation RootViewController
{
    AFJSONRequestOperation *operation;
    UIBarButtonItem *loginBarBtn;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [self getUIColorObjectFromHexString:@"#DDDDDD" alpha:1];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Repo" object:nil queue:nil usingBlock:^(NSNotification *event) {
        NSString *code = [[event userInfo] objectForKey:@"code"];
        [self receiveCode:code];
        NSLog(@"OAuthCode = %@",code);
        NSLog(@"Received the code!");
    }];
    
    UIImage *settingsImg = [UIImage imageNamed:@"settings_circle.png"];
    self.settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsBtn setBackgroundImage:settingsImg forState:UIControlStateNormal];
    self.settingsBtn.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 38,[[UIScreen mainScreen] bounds].size.height - 63,33,33);//
    [self.settingsBtn addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsBtn];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect fixedFrame = self.settingsBtn.frame;
    fixedFrame.origin.y = ([[UIScreen mainScreen] bounds].size.height - 63) + scrollView.contentOffset.y;
    self.settingsBtn.frame = fixedFrame;
}


- (void) receiveCode:(NSString*)code {
    if ( !code ) {
        NSLog(@"Code issue");
        return;
    };
    
    [[GitHubOAuth sharedClient] requestAccessToken:code completionHandler:^(NSString *token, AFHTTPRequestOperation *operation, NSError *error) {
//        [self receiveToken:token];
        NSLog(@"Got token %@", token);
        
        [RFKeychain setPassword:token account:@"GitHub" service:@"Repo"];
        [self createClient:token];
    }];
    
}

- (void) createClient:(NSString *)token {
    OCTClient *client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
}

- (void) checkSkies {
    
}

- (void) star:(NSString *)repository client:(OCTClient *)client {
    //PUT /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/%@" stringByAppendingString:repository];
    [client putPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Starred successfully");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful stargazing");
    }];
}

- (void) unstar:(NSString *)repository client:(OCTClient *)client {
    //DELETE /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/%@" stringByAppendingString:repository];
    [client deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Unstarred successfully");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful unstarring");
    }];
}

- (void) gazingRepos:(OCTClient *)client completionHandler:(void (^)(id))handler  {
    [client getPath:@"/user/starred" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        handler(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Gazing request failed.");
    }];
}

//    NSLog(@"Unsuccessful unstarring");

//    switch (status) {
//        case 204:
//            
//            break;
//            
//        case 404:
//            break;
//    }
//    if responseObject
    
//}

//GET /user/starred

- (void)addItemViewController:(RepoViewController *)controller didFinishEnteringItem:(BOOL)item
{
    NSLog(@"This was returned from the RepoViewController %hhd",item);
    self.shouldReload = item;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self testInternetConnection];
    
    //See if they're authorized
    self.keychainToken = [RFKeychain passwordForAccount:@"GitHub" service:@"Repo"];
    
////    if (self.keychainToken) {
////        NSLog(@"The user is authorized.");
////        NSLog(@"The token is: %@", self.keychainToken);
////        loginBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
////    } else {
//        loginBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(login:)];
////    }
//    self.navigationItem.leftBarButtonItem = loginBarBtn;
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
//TODO - What networking on/off bug was this catching?
//            if (self.hud.hidden == NO) { //Double check it's gone
//                [self.hud hide:YES];
//            }
            

        });
    };
    
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            [self.hud hide:YES];
            self.sad_hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            self.sad_hud.mode = MBProgressHUDModeText;
            self.sad_hud.animationType = MBProgressHUDAnimationZoomIn;
            self.sad_hud.labelText = @"No internet.";
            
            self.tableView.allowsSelection = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (void)settings:(id)sender
{
    [self.hud hide:YES];
    TableViewController *langList = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *langTable = [[UINavigationController alloc] initWithRootViewController:langList];
    [self presentViewController:langTable animated:YES completion:nil];
    self.shouldReload = YES;
}

- (void)connect:(id)sender {
    [[GitHubOAuth sharedClient] authorizeWithParams:@{@"scope": @"public_repo"}];
}

- (void)login:(id)sender
{
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 110)];
        
        CGRect welcomeLabelRect = contentView.bounds;
//        welcomeLabelRect.origin.y = 50;
//        welcomeLabelRect.size.height = 40;
        UIImage *connectWithGitHub = [UIImage imageNamed:@"connect_with_github_white.png"];
        
        UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [connectButton setBackgroundImage:connectWithGitHub forState:UIControlStateNormal];
        connectButton.frame = CGRectMake(22,15,228,40);
        
        [connectButton addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:connectButton];
    
        CGRect infoLabelRect = CGRectInset(contentView.bounds, 5, 25);
        infoLabelRect.origin.y = CGRectGetMaxY(welcomeLabelRect)+5;
        infoLabelRect.size.height -= CGRectGetMinY(infoLabelRect);
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:infoLabelRect];
        infoLabel.text = @"Connect your GitHub account using OAuth to star repositories you like";
        infoLabel.numberOfLines = 3;
        infoLabel.textColor = [self getUIColorObjectFromHexString:@"C1C1C1" alpha:1];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        UIFont *infoFont = [UIFont boldSystemFontOfSize:13];
        infoLabel.font = infoFont;
//        infoLabel.shadowColor = [UIColor blackColor];
//        infoLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:infoLabel];
        
        [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
}

- (void)logout:(id)sender
{
    //TODO Log out
    //    [[GitHubOAuth sharedClient] authorizeWithParams:@{@"scope": @"public_repo"}];
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
{//TODO constants here
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
        cell.repoTitle.text = @"No projects starred or forked.";
        cell.repoTitle.textColor = [self getUIColorObjectFromHexString:@"#555555" alpha:1];
        cell.repoDescription.text = @"Go give the language some love :)";
        cell.contestIcon.image = [UIImage imageNamed:@"no_repos.png"];
        
        return cell;
    } else if ([readmeURL isEqualToString: @"Readme link unavailable."]){
        return cell;
    } else {
        NSURL *url = [NSURL URLWithString:readmeURL];

        NSString *githubUser   = url.pathComponents[1];
        NSString *repoTitle    = url.pathComponents[2];
        NSArray *directoryParts = @[githubUser, repoTitle];
        NSString *repoDirectory = [directoryParts componentsJoinedByString:@" / "];

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
        [[NSMutableAttributedString alloc] initWithString:repoDirectory attributes:attrs];
        [attributedText setAttributes:subAttrs range:rangeSlash];
        
        cell.backgroundColor      = [self getUIColorObjectFromHexString:@"#FBFBFB" alpha:1];
        [cell.repoTitle setAttributedText:attributedText];
        
        cell.repoDescription.text = readmeText;
        cell.repoDescription.textColor = [self getUIColorObjectFromHexString:@"#555555" alpha:1];
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
    [self.hud hide:YES];
    NSDictionary *dictionary = [self.dataArray objectAtIndex:indexPath.section];
    NSArray *readmeURLArray = [dictionary objectForKey:@"readme_url"];
    NSString *readmeURL = [readmeURLArray objectAtIndex:indexPath.row];
    
    if ([readmeURL isEqualToString: @"NOTHING"]) {
    } else {
        RepoViewController *webView = [[RepoViewController alloc] init];
        webView.url = [NSURL URLWithString:readmeURL];
        webView.delegate = self;
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"readme_click" properties:@{
         @"read": readmeURL
         }];
        [self.sad_hud hide:YES];
        [self presentViewController:webView animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end