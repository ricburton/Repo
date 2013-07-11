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

-(void)viewDidAppear:(BOOL)animated
{
    NSArray *arrayOfLangs = [NSArray arrayWithContentsOfFile:self.langPrefsPath];
    
    if (arrayOfLangs.count > 0) {
    //Fetch latest READMEs
        
    //Add them to a grouped TableView
    
        
    } else {
        [self.navigationController presentModalViewController:self.langTable animated:YES];
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

