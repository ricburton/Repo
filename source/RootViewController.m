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
#import "Mixpanel.h"
#import "Constants.h"
#import "Tokens.h"


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
@property (strong, nonatomic) UIButton *trendingBtn;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) KGModal *modal;
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
    self.tableView.separatorColor = [UIColor colorWithHexString:@"#DDDDDD"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Repo" object:nil queue:nil usingBlock:^(NSNotification *event) {
        NSString *code = [[event userInfo] objectForKey:@"code"];
        [self.modal hide];
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
    
    CGRect fixedTrendingFrame = self.trendingBtn.frame;
    fixedTrendingFrame.origin.y = ([[UIScreen mainScreen] bounds].size.height - 73.65) + scrollView.contentOffset.y;
    self.trendingBtn.frame = fixedTrendingFrame;
}


- (void) receiveCode:(NSString*)code {
    if ( !code ) {
        NSLog(@"Code issue");
        return;
    };
    
    [[GitHubOAuth sharedClient] requestAccessToken:code completionHandler:^(NSString *token, AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Got token %@", token);
        
        [RFKeychain setPassword:token account:KEYCHAIN_ACCOUNT service:KEYCHAIN_SERVICE];
        [self createClient:token];
    }];
}

- (void) pushStarred {
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.animationType = MBProgressHUDAnimationZoomIn;
    self.hud.labelText = @"Loading";
    self.dataArray = [[NSMutableArray alloc]init];
    
    [self.client getPath:@"/user/starred" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
        NSArray *readme_urls = [responseObject valueForKeyPath:@"html_url"];
        NSLog(@"urls: %@", readme_urls);
        NSArray *descriptions = [responseObject valueForKeyPath:[NSString stringWithFormat:@"description"]];
        NSLog(@"descriptions: %@", descriptions);
        
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:descriptions forKey:@"descriptions"];
        [dataDict setObject:readme_urls forKey:@"readme_url"];
        
        self.arrayOfLangs = @[@"What you've starred"];
        [self.dataArray addObject:dataDict];
        [self.tableView reloadData];
        
        UIImage *trendingImg = [UIImage imageNamed:@"trending_circle.png"];
        self.trendingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.trendingBtn setImage:trendingImg forState:UIControlStateNormal];
        [self.trendingBtn setFrame: CGRectMake(0,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
        [self.trendingBtn setContentMode:UIViewContentModeCenter];
        [self.trendingBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 14.5, 10, 85.5)];
        [self.trendingBtn addTarget:self action:@selector(trending:) forControlEvents:UIControlEventTouchUpInside];
        [self.githubBtn removeFromSuperview];
        [self.settingsBtn removeFromSuperview];

        [self.view addSubview:self.trendingBtn];
        [self.hud hide:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Username not retrieved.");
    }];
}

- (void)trending:(id)sender
{
    self.shouldReload = TRUE;
    [self testInternetConnection];
    [self.view addSubview:self.githubBtn];
    [self.view addSubview:self.settingsBtn];
    [self.trendingBtn removeFromSuperview];
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
            [self pushStarred];
            
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"starred_click"];
            
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
            infoLabel.textColor = [UIColor colorWithHexString:@"C1C1C1"];
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.backgroundColor = [UIColor clearColor];
            UIFont *infoFont = [UIFont boldSystemFontOfSize:13];
            infoLabel.font = infoFont;
            [contentView addSubview:infoLabel];
            
            self.modal = [KGModal sharedInstance];
            self.modal.modalBackgroundColor = [UIColor colorWithHexString:@"96C1C1C1"];
            [self.modal showWithContentView:contentView andAnimated:YES];
            
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"connect_with_github_click"];
        }
}

- (void)logout:(id)sender
{
    //TODO Log out
    //    [[GitHubOAuth sharedClient] authorizeWithParams:@{@"scope": @"public_repo"}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *colorDic = COLORS_AND_HEX_VALUES

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, self.tableView.frame.size.width, 35)];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [label setTextColor:[UIColor colorWithHexString:@"fff"]];
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
    [label setBackgroundColor:[UIColor colorWithHexString:sectionColor]];
    [view setBackgroundColor:[UIColor colorWithHexString:sectionColor]];
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
    NSString *description = [readmeArray objectAtIndex:indexPath.row]; //TODO keep language consistent.
    NSString *readmeText;
    if (description == (id)[NSNull null] || description.length == 0 ) {
        readmeText = @"No description available.";
    } else {
        readmeText = description;
    }
    
    NSArray *readmeURLArray = [dictionary objectForKey:@"readme_url"];
    NSString *readmeURL = [readmeURLArray objectAtIndex:indexPath.row];
        
    NSLog(@"readmeURL: %@", readmeURL);
    NSLog(@"description: %@", description);
    NSLog(@"description: %@", readmeText);
    if ([readmeURL isEqualToString: @"NOTHING"]) {
        NSLog(@"No stars or forks");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.repoTitle.text = @"No projects starred or forked.";
        cell.repoTitle.textColor = [UIColor colorWithHexString:@"#555"];
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
        UIColor *boldColor  = [UIColor colorWithHexString:@"#3A85D6"];
        UIFont *slashFont = [UIFont boldSystemFontOfSize:fontSize];
        UIColor *slashColor = [UIColor colorWithHexString:@"#999"];
        
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
        
        cell.backgroundColor      = [UIColor colorWithHexString:@"#FBFBFB"];
        [cell.repoTitle setAttributedText:attributedText];
        
        cell.repoDescription.text = readmeText;
        cell.repoDescription.textColor = [UIColor colorWithHexString:@"#555555"];
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