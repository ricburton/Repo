#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //What's this for?

#import "RootViewController.h"
//#import "ReadmeViewController.h"
#import "CRTableViewController.h"
#import "AFNetworking.h"


@interface RootViewController ()
//@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation RootViewController
@synthesize arrayOfLangs;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set up the view
    self.title = @"GitHub Explore";
    
    UIBarButtonItem *langButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Settings"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(settings:)];
    
    self.navigationItem.rightBarButtonItem = langButton;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Setting Up Activity Indicator View
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.center = self.view.center;
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    
    //Prepare popover language selector
    self.langList = [[CRTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.langTable = [[UINavigationController alloc] initWithRootViewController:_langList];
    [(CRTableViewController *)self.langList setParent:self];
}

- (void)viewDidAppear:(BOOL)animated {
    //Check to see if some favourite languages have already been set.
    self.directories   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documents     = [self.directories lastObject];
    self.filePathLangs = [self.documents stringByAppendingPathComponent:@"langs.plist"];
    NSLog(@"DOCUMENTS: %@", self.documents);
    
    arrayOfLangs = [NSMutableArray arrayWithContentsOfFile:self.filePathLangs];
    NSLog(@"arrayOfLangs: %@", arrayOfLangs);
        
    if (arrayOfLangs == nil || arrayOfLangs.count == 0) {
        NSLog(@"FAIL");
        [self.navigationController presentModalViewController:self.langTable animated:YES];
    } else {
        //Fetch latest READMEs
        
        //Add them to a grouped TableView
        NSLog(@"PASS");
                
        //Set up the params for the GET request
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: arrayOfLangs, @"languages", nil];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://githubber.herokuapp.com"]];//localhost:9292
        httpClient.parameterEncoding = AFJSONParameterEncoding;
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:@"/readmes"
                                                          parameters:params];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSLog(@"response first: %@", JSON);
            response_data = JSON;
            
            //Prepare the data
            dataArray = [[NSMutableArray alloc]init];
            
            for( NSString* language in arrayOfLangs )
            {
                //TODO - how to make this work without a hack?
                NSArray *readmes = [response_data valueForKeyPath:[NSString stringWithFormat:@"%@.readme_raw",language]];
                NSArray *repo_urls = [response_data valueForKeyPath:[NSString stringWithFormat:@"%@.repo",language]];
                
                NSLog(@"Repo_urls: %@ for %@",repo_urls,language);
                
                if (readmes && repo_urls) {
                    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:readmes forKey:@"readmes"];
                    [dataDict setObject:repo_urls forKey:@"repo"];
                    
                    [dataArray addObject:dataDict];
                } else {
                    NSLog(@"Readmes or Repo URLs are empty");
                }
            }
                   
            [self.activityIndicatorView stopAnimating];
            [self.tableView setHidden:NO];
            [self.tableView reloadData];
        
        } failure:nil];//^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {NSLog(@"JSON Error")}; //TODO error message: http://www.raywenderlich.com/30445/afnetworking-crash-course
        [operation start];
    }
}

- (void)settings:(id)sender
{
[self presentModalViewController:self.langTable animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"readmes"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return arrayOfLangs[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO Remove repetitio
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *readmeArray = [dictionary objectForKey:@"readmes"];
    NSString *readmeText = [readmeArray objectAtIndex:indexPath.row];
    

    
//    ReadmeViewController *readmeView = [[ReadmeViewController alloc] init];
//    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:];
//    self.navigationItem.leftBarButtonItem = closeButton;
    //    webView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    
    // add long text to label
    myLabel.text = readmeText;
    myLabel.backgroundColor = [UIColor whiteColor];
    
    
    // start with a raw markdown string
    NSString *rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *emFont = [UIFont fontWithName:@"AvenirNext-MediumItalic" size:15.0];
    
    // create a color attribute for paragraph text
    UIColor *color = [UIColor purpleColor];
    
//    // create a dictionary to hold your custom attributes for any Markdown types
//    NSDictionary *attributes = @{
//                                 @(EMPH): @{NSFontAttributeName : emFont,},
//                                 @(PARA): @{NSForegroundColorAttributeName : color,}
//                                 };
//    
//    // parse the markdown
//    NSAttributedString *prettyText = markdown_to_attr_string(rawText,0,attributes);
//    
//    // assign it to a view object
//    myTextView.attributedText = prettyText;
    
    
    [scrollView addSubview:myLabel];
    // set line break mode to word wrap
    myLabel.lineBreakMode = UILineBreakModeWordWrap;
    // set number of lines to zero
    myLabel.numberOfLines = 0;
    // resize label
    [myLabel sizeToFit];
    
    UIViewController *readmeViewController = UIViewController.new;
    
    [self.view addSubview:scrollView];
    
//    [self presentViewContoller:readmeViewController animated:YES completion:nil];
    
//    [self dismissModalViewControllerAnimated:NO];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *readmeArray = [dictionary objectForKey:@"readmes"];
    NSString *readmeText = [readmeArray objectAtIndex:indexPath.row];
    
    NSArray *repoArray = [dictionary objectForKey:@"repo"];
    NSString *repoURL = [repoArray objectAtIndex:indexPath.row];
    NSString *repoURLStrip = [repoURL stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = repoURLStrip;
    cell.detailTextLabel.text = readmeText;
    //Todo - change to READMEs within section

    return cell;
}

@end

