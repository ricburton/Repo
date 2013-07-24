#import "ReadmeViewController.h"

@interface ReadmeViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ReadmeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *myBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width,self.view.frame.size.height)];
    
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ( 7 == [[versionCompatibility objectAtIndex:0] intValue] ) { /// iOS7 is installed
        
        myBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width,self.view.frame.size.height)];
    }
    
    [self.view addSubview:self.webView];
    
    [self.view addSubview:myBar];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(remove:)];
    UINavigationItem *item = [[UINavigationItem alloc]init];
    [item setRightBarButtonItem:backButton];
    [myBar setItems:[NSArray arrayWithObject:item]];

    self.webView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    
    // Setting Up Activity Indicator View
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.center = self.view.center;
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];

}

- (void)remove:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicatorView stopAnimating];
    NSLog(@"Error");
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start laoding");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    [self.activityIndicatorView startAnimating];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finish loading");
    [self.activityIndicatorView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
