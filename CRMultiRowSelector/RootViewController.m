#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //What's this for?

#import "RootViewController.h"
#import "CRTableViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.langList = [[CRTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.langTable = [[UINavigationController alloc] initWithRootViewController:_langList];
    [(CRTableViewController *)self.langList setParent:self];
    
    UIBarButtonItem *langButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Settings"
                                    style:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(settings:)];

    self.title = @"GitHub Explore";
    
    self.navigationItem.rightBarButtonItem = langButton;
    
	    
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    self.latestProjects = [json objectForKey:@"projects"];
    
    NSLog(@"loans: %@", self.latestProjects);
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
    UILabel *langLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
    [langLabel setTextColor:[UIColor blackColor]];
    [langLabel setBackgroundColor:[UIColor clearColor]];
    [langLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]]; //this is correct font
    
    NSDictionary* projects = [self.latestProjects objectAtIndex:0];
    
    NSMutableArray *arrayOfLangs = [[NSMutableArray alloc] initWithContentsOfFile:self.langPrefsPath];
    
    
    if (arrayOfLangs.count > 0) {
        
    } else {
        [self.navigationController presentModalViewController:self.langTable animated:YES];
        [[self view] addSubview:langLabel];
    }


    
}


- (void)settings:(id)sender
{
[self presentModalViewController:self.langTable animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

