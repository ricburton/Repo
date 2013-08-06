#import "ReadmeViewController.h"
#import "MBProgressHUD.h"
#import "RootViewController.h"
#import "Reachability.h"

@interface ReadmeViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ReadmeViewController
{
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.delegate addItemViewController:self didFinishEnteringItem:NO];
    
    NSArray *versionParts = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    BOOL modernStyle = (7 >= [[versionParts objectAtIndex:0] intValue]);
    CGFloat barHeight = (modernStyle ? 44  : 44);
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, barHeight)];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, barHeight, self.view.frame.size.width,self.view.frame.size.height)];
    
    [self.view addSubview:self.webView];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.labelText = @"Loading";
    [self.view addSubview:bar];
    
    UIImage *removeImg = [UIImage imageNamed:@"remove.png"];
    
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setBackgroundImage:removeImg forState:UIControlStateNormal];
    removeBtn.frame = CGRectMake(0,0,33,19);
    
    [removeBtn addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveBarBtn = [[UIBarButtonItem alloc] initWithCustomView:removeBtn];
    
    self.navigationItem.rightBarButtonItem = saveBarBtn;
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    [item setRightBarButtonItem:saveBarBtn];
    [bar setItems:[NSArray arrayWithObject:item]];
    
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
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
