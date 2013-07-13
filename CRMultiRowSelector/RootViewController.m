#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //What's this for?

#import "RootViewController.h"
#import "CRTableViewController.h"
#import "SimpleTableCell.h"

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
    }
    
    [self.tableView reloadData];


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
    NSString *CellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //Todo - change to READMEs within section
    NSString *language = [arrayOfLangs objectAtIndex:[indexPath row]];
    NSString *blurb = @"blurb..";
    [cell.textLabel setText:language];
    [cell.detailTextLabel setText:blurb];

    return cell;
}

@end

