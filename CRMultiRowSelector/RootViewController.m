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
    
//    arrayOfLangs = [NSArray arrayWithContentsOfFile:self.langPrefsPath];
    arrayOfLangs = [NSArray arrayWithObjects:@"Python", @"Objective C", @"Ruby", @"JavaScript", nil];
    
    UITableView *readmes = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
//    readmes.delegate = self;
//    readmes.dataSource = arrayOfLangs;

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
    
    if (arrayOfLangs.count > 0) {
        //Fetch latest READMEs
        
        //Add them to a grouped TableView
        
        [self.view addSubview:readmes];
        
    } else {
        [self.navigationController presentModalViewController:self.langTable animated:YES];
    }
    
    
}

//- (void)viewDidAppear:(BOOL)animated {
//
//    
//
//    
//}

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

