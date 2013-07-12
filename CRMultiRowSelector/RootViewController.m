#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //What's this for?

#import "RootViewController.h"
#import "CRTableViewController.h"

@interface RootViewController ()
//@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation RootViewController
@synthesize arrayOfLangs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil //TODO what is this doing?
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
    
    //Set up the view
    self.title = @"GitHub Explore";
    
    UIBarButtonItem *langButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Settings"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(settings:)];
    
    self.navigationItem.rightBarButtonItem = langButton;

    
    
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
    
    //Add the readme tableview
    UITableView *readmes = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    if (arrayOfLangs == nil || arrayOfLangs.count == 0) {
        NSLog(@"FAIL");
        [self.navigationController presentModalViewController:self.langTable animated:YES];
    } else {
        //Fetch latest READMEs
        
        //Add them to a grouped TableView
        NSLog(@"PASS");
        [self.view addSubview:readmes];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrayOfLangs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier"; //Keeps memory useage down. Is this needed?
    [tableView registerClass:[UITableView class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //Todo - change to READMEs within section
    NSString *language = [arrayOfLangs objectAtIndex:[indexPath row]];
    [cell.textLabel setText:language];
    return cell;
}


@end

