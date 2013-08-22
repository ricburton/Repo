#import "RepoViewController.h"
#import "MBProgressHUD.h"
#import "RootViewController.h"
#import "Reachability.h"
#import "GitHubOAuth.h"
#import "Octokit.h"

@interface RepoViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIButton *starBtn;
@property (strong, nonatomic) MBProgressHUD *starHud;
@property (strong, nonatomic) MBProgressHUD *unstarHud;

@end

@implementation RepoViewController
{
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"repo: %@",self.repo);
    NSLog(@"url: %@",self.url);

    [self.delegate addItemViewController:self didFinishEnteringItem:NO];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    
    [self.view addSubview:self.webView];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.labelText = @"Loading";
    
    for (id subView in [self.view subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }
    
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    
    UIImage *removeImg = [UIImage imageNamed:@"x_circle.png"];
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setImage:removeImg forState:UIControlStateNormal];
    [removeBtn setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 133,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
    [removeBtn setContentMode:UIViewContentModeCenter];
    [removeBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 85.5, 10, 14.5)];
    [removeBtn addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeBtn];
    
    
    self.starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.starBtn setFrame: CGRectMake(0,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
    [self.starBtn setContentMode:UIViewContentModeCenter];
    [self.starBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 14.5, 10, 85.5)];
    [self.starBtn setImage:[UIImage imageNamed:@"star_circle.png"] forState:UIControlStateNormal];
    [self.starBtn setImage:[UIImage imageNamed:@"unstar_circle.png"] forState:UIControlStateSelected];

    [self.view addSubview:self.starBtn];
}

- (void) viewDidAppear:(BOOL)animated {
    [self updateStarButton];
}

- (void) updateStarButton {
    if (self.client)
    {
        //Starred already?
        
        NSString *repository = self.repo;
        OCTClient *client = self.client;
        
        //GET /user/starred/:owner/:repo
        NSString *path = [@"/user/starred/" stringByAppendingString:repository];
        NSLog(@"path: %@", path);
        [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Is a stargazer");
            [self.starBtn addTarget:self action:@selector(unstar:) forControlEvents:UIControlEventTouchUpInside];
            self.starBtn.selected = TRUE;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Not a stargazer");

            [self.starBtn addTarget:self action:@selector(star:) forControlEvents:UIControlEventTouchUpInside];
            self.starBtn.selected = FALSE;
        }];
//        [self.starHud hide:YES];
//        [self.unstarHud hide:YES];

    } else {
        //Not logged in so no starring.
    }
}

- (void) star:(id)sender
{
    self.starHud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    self.starHud.mode = MBProgressHUDModeIndeterminate;
    self.starHud.animationType = MBProgressHUDAnimationZoomIn;
    
    NSString *repository = self.repo;
    OCTClient *client = self.client;

    //PUT /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/" stringByAppendingString:repository];
    [client putPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Starred successfully");
        [self.starBtn setSelected: TRUE];
        [self.starHud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful stargazing");
    }];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"star_click" properties:@{
     @"starred": self.url
     }];
    
    [self updateStarButton];
}

- (void) unstar:(id)sender
{
    NSString *repository = self.repo;
    OCTClient *client = self.client;

    //DELETE /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/" stringByAppendingString:repository];
    [client deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Unstarred successfully");
        [self.starBtn setSelected: FALSE];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful unstarring");
    }];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"star_click" properties:@{
     @"unstarred": self.url
     }];
    
    [self updateStarButton];
}

- (void)remove:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    [self.webView stopLoading];
    self.webView.delegate = nil;
}
    
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [hud hide: YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    [hud hide: NO];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"readme_load" properties:@{
     @"load": self.url
     }];
}

@end
