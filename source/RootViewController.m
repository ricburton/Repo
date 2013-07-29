#import "RootViewController.h"
#import "TableViewController.h"
#import "AFNetworking.h"
#import "ReadmeViewController.h"

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

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"README";
    
    UIBarButtonItem *langButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Settings"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(settings:)];
    
    self.navigationItem.rightBarButtonItem = langButton;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.directories   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documents     = [self.directories lastObject];
    self.filePathLangs = [self.documents stringByAppendingPathComponent:@"langs.plist"];
    NSLog(@"DOCUMENTS: %@", self.documents);
    
    self.arrayOfLangs = [NSMutableArray arrayWithContentsOfFile:self.filePathLangs];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.center = self.view.center;
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];

    NSLog(@"PASS");
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.arrayOfLangs, @"languages", nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://githubber.herokuapp.com"]];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"/readmes"
                                                      parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self.activityIndicatorView startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSLog(@"response first: %@", JSON);
        self.response_data = JSON;
        
        self.dataArray = [[NSMutableArray alloc]init];
        
        for( NSString* language in self.arrayOfLangs )
        {
            NSArray *descriptions = [self.response_data valueForKeyPath:[NSString stringWithFormat:@"%@.description",language]];
            NSArray *readme_urls = [self.response_data valueForKeyPath:[NSString stringWithFormat:@"%@.readme_url",language]];
            
            NSLog(@"Repo_urls: %@ for %@",readme_urls,language);
            
            if (descriptions && readme_urls) {
                NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:descriptions forKey:@"descriptions"];
                [dataDict setObject:readme_urls forKey:@"readme_url"];
                
                [self.dataArray addObject:dataDict];
            } else {
                NSLog(@"Readmes or readme_urls are empty");
            }
        }
        
        [self.activityIndicatorView stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
        
    } failure:nil];
    [operation start];
}

- (void)settings:(id)sender
{
    TableViewController *langList = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *langTable = [[UINavigationController alloc] initWithRootViewController:langList];
    [self presentViewController:langTable animated:YES completion:nil];
    
    [self.activityIndicatorView stopAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [self.dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"descriptions"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.arrayOfLangs[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [self.dataArray objectAtIndex:indexPath.section];
    NSArray *readmeURLArray = [dictionary objectForKey:@"readme_url"];
    NSString *readmeURL = [readmeURLArray objectAtIndex:indexPath.row];
    
    ReadmeViewController *webView = [[ReadmeViewController alloc] init];
    webView.url = [NSURL URLWithString:readmeURL];
    
    [self presentViewController:webView animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [self.dataArray objectAtIndex:indexPath.section];
    NSArray *readmeArray = [dictionary objectForKey:@"descriptions"];
    NSString *readmeText = [readmeArray objectAtIndex:indexPath.row];
    
    NSArray *readmeURLArray = [dictionary objectForKey:@"readme_url"];
    NSString *readmeURL = [readmeURLArray objectAtIndex:indexPath.row];
    NSLog(@"response first: %@", readmeURL);
    if ([readmeURL  isEqual: @"Readme link unavailable."]) {
        NSLog(@"No Readme link.");
        return cell;
    } else {
        NSString *readmeURLStrip = [readmeURL stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
        NSRange range = [readmeURLStrip rangeOfString:@"/blob/"];//FIXME sometimes not a blob.
        NSString *repoTitle = [readmeURLStrip substringToIndex:range.location];
        
        cell.textLabel.font  = [UIFont fontWithName: @"Arial" size: 16.0];
        cell.textLabel.text = repoTitle;
        cell.detailTextLabel.text = readmeText;
        cell.detailTextLabel.font = [UIFont fontWithName: @"Arial" size: 13.0];

        return cell;
    }
}

@end

