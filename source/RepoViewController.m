#import "RepoViewController.h"
#import "MBProgressHUD.h"
#import "RootViewController.h"
#import "Reachability.h"

@interface RepoViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation RepoViewController
{
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.delegate addItemViewController:self didFinishEnteringItem:NO];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    
    [self.view addSubview:self.webView];
    
    UIImage *removeImg = [UIImage imageNamed:@"x_circle.png"];
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setBackgroundImage:removeImg forState:UIControlStateNormal];
    removeBtn.frame = CGRectMake(8,8,33,33);
    [removeBtn addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeBtn];
    
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
