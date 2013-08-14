#import "GitHubConnectView.h"

@interface GitHubConnectView ()

@end

@implementation GitHubConnectView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repo_icon_github_connect_view.png"]];
    [self addSubview:imageView];
}

@end
