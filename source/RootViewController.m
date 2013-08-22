#import "RootViewController.h"
#import "LanguageController.h"
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
@property (strong, nonatomic) UIButton *githubBtn;
@property (strong, nonatomic) NSString *username;
//@property (strong, nonatomic) UITableView *tableView;TODO fix sections?

@end

@implementation RootViewController
{
    AFJSONRequestOperation *operation;
    UIBarButtonItem *loginBarBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,[[UIScreen mainScreen] bounds].size.height - 20) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    [[self navigationController] setNavigationBarHidden:YES];
    self.tableView.tableFooterView = [[UIView alloc]init];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [self getUIColorObjectFromHexString:@"#DDDDDD" alpha:1];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Repo" object:nil queue:nil usingBlock:^(NSNotification *event) {
        NSString *code = [[event userInfo] objectForKey:@"code"];
        [self receiveCode:code];
        NSLog(@"OAuthCode = %@",code);
    }];
    
    
    UIImage *settingsImg = [UIImage imageNamed:@"settings_circle.png"];
    self.settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsBtn setImage:settingsImg forState:UIControlStateNormal];
    [self.settingsBtn setFrame: CGRectMake([[UIScreen mainScreen] bounds].size.width - 133,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];//TODO bounds shortcut?
    [self.settingsBtn setContentMode:UIViewContentModeCenter];
    [self.settingsBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 85.5, 10, 14.5)];
    [self.settingsBtn addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsBtn];
    
    UIImage *githubImg = [UIImage imageNamed:@"github_circle.png"];
    self.githubBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.githubBtn setImage:githubImg forState:UIControlStateNormal];
    [self.githubBtn setFrame: CGRectMake(0,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
    [self.githubBtn setContentMode:UIViewContentModeCenter];
    [self.githubBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 14.5, 10, 85.5)];
    [self.githubBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.githubBtn];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect fixedFrame = self.settingsBtn.frame;
    fixedFrame.origin.y = ([[UIScreen mainScreen] bounds].size.height - 73.65) + scrollView.contentOffset.y;
    self.settingsBtn.frame = fixedFrame;
    
    CGRect fixedGitHubFrame = self.githubBtn.frame;
    fixedGitHubFrame.origin.y = ([[UIScreen mainScreen] bounds].size.height - 73.65) + scrollView.contentOffset.y;
    self.githubBtn.frame = fixedGitHubFrame;
}


- (void) receiveCode:(NSString*)code {
    if ( !code ) {
        NSLog(@"Code issue");
        return;
    };
    
    [[GitHubOAuth sharedClient] requestAccessToken:code completionHandler:^(NSString *token, AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Got token %@", token);
        
        [RFKeychain setPassword:token account:@"GitHub" service:@"Repo"];
        [self createClient:token];
    }];
    
}

- (void) createClient:(NSString *)token {
    self.client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
    [self.client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    //GET /user/starred/:owner/:repo
    if (self.client) {

        [self.client getPath:@"/user" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.username = [responseObject objectForKey:@"login"];
            NSLog(@"Username: %@", self.username);

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Username not retrieved.");
        }];
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance]; //TODO do i have to repeat this?
    [mixpanel identify:self.username];
    [mixpanel.people set:@"Opened the app" to:[NSDate date]];
}

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
    
    if (self.keychainToken) {
        NSLog(@"Creating the client");
        [self createClient:self.keychainToken];
    } else {
        self.client = nil;
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
                
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://githubtrending.herokuapp.com"]];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                        path:@"/trending"
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
                    
                    for( NSString* rawLanguage in self.arrayOfLangs )
                    {
                        //TODO Fix language-naming across the app.
                        NSString *languageWithoutPercent = [rawLanguage stringByReplacingOccurrencesOfString:@"%20" withString:@"-"];
                        NSString *languageWithoutSpace = [languageWithoutPercent stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                        NSString *language = [languageWithoutSpace lowercaseString];
                        
                        NSString *readme_url_data = [NSString stringWithFormat:@"%@.readme",language];
                        NSLog(@"Readme URL%@",readme_url_data);
                        NSArray *readme_urls = [self.response_data valueForKeyPath:readme_url_data];
                        
                        NSArray *descriptions = [self.response_data valueForKeyPath:[NSString stringWithFormat:@"%@.description",language]];
                        
                        if (descriptions && readme_urls) {
                            NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:descriptions forKey:@"descriptions"];
                            [dataDict setObject:readme_urls forKey:@"readme_url"];
                            
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
                    [self.tableView setHidden: NO];
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
    UIViewController *langList = LanguageController.new;
    [self presentViewController:langList animated:YES completion:nil];
    self.shouldReload = YES;
}

- (void)connect:(id)sender {
    [[GitHubOAuth sharedClient] authorizeWithParams:@{@"scope": @"public_repo"}];
}

- (void)login:(id)sender
{
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 110)];
        if (self.client) {
            
            contentView.frame = CGRectMake(0, 0, 280, 60);
            CGRect welcomeLabelRect = contentView.bounds;
            welcomeLabelRect.origin.y = 20;
            welcomeLabelRect.size.height = 20;
            UIFont *welcomeLabelFont = [UIFont boldSystemFontOfSize:17];
            UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelRect];
            welcomeLabel.text = @"You've connected.";
            welcomeLabel.font = welcomeLabelFont;
            welcomeLabel.textColor = [UIColor whiteColor];
            welcomeLabel.textAlignment = NSTextAlignmentCenter;
            welcomeLabel.backgroundColor = [UIColor clearColor];
            [contentView addSubview:welcomeLabel];
            
        } else {
            CGRect welcomeLabelRect = contentView.bounds;
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
            infoLabel.text = @"Connect your GitHub account using OAuth to star the repositories you like.";
            infoLabel.numberOfLines = 3;
            infoLabel.textColor = [self getUIColorObjectFromHexString:@"C1C1C1" alpha:1];
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.backgroundColor = [UIColor clearColor];
            UIFont *infoFont = [UIFont boldSystemFontOfSize:13];
            infoLabel.font = infoFont;
            [contentView addSubview:infoLabel];
        }
    
        KGModal *modal = [KGModal sharedInstance];
        modal.modalBackgroundColor = [self getUIColorObjectFromHexString:@"262626" alpha:0.96];
       [modal showWithContentView:contentView andAnimated:YES];
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
        cell.contestIcon.image    = [UIImage imageNamed:@"repo_icon.png"];
         
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
        NSURL *url = [NSURL URLWithString:readmeURL]; //TODO Tidy this up
        webView.url = url;
        NSString *githubUser   = url.pathComponents[1];
        NSString *repoTitle    = url.pathComponents[2];
        NSArray *directoryParts = @[githubUser, repoTitle];
        NSString *repoDirectory = [directoryParts componentsJoinedByString:@"/"];
        webView.repo = repoDirectory;
        
        if (self.client) {
            webView.client = self.client;
        }
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